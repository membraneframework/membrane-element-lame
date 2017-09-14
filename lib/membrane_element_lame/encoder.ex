defmodule Membrane.Element.Lame.Encoder do
  use Membrane.Element.Base.Filter
  alias Membrane.Element.Lame.Encoder.Options
  alias Membrane.Element.Lame.EncoderNative
  alias Membrane.Caps.Audio.Raw
  alias Membrane.Caps.Audio.MPEG
  alias Membrane.Buffer
  use Membrane.Mixins.Log, tags: :membrane_element_lame

  @samples_per_frame 1152
  @sample_size 4

  def_known_source_pads %{
    :source => {:always, :pull, [
      %MPEG{
        channels: 2,
        sample_rate: 44100,
      }
    ]}
  }

  def_known_sink_pads %{
    :sink => {:always, {:pull, demand_in: :bytes}, [
      %Raw{
        format: :s24le,
        sample_rate: 44100,
        channels: 2,
      }
    ]}
  }


  @doc false
  def handle_init(%Options{} = options) do
    {:ok, %{
      native: nil,
      queue: <<>>,
      options: options,
      eos: false,
    }}
  end
  
  @doc false
  def handle_prepare(:stopped, state) do
    with {:ok, native} <- EncoderNative.create(
      state[:options].channels,
      state[:options].bitrate,
      Options.map_quality_to_value(state[:options].quality))
    do
      caps = %MPEG{channels: 2, sample_rate: 44100}
      {{:ok, caps: {:source, caps}}, %{state | native: native}}
    else
      {:error, reason} -> 
        {{:error, reason}, state}
    end
  end
  def handle_prepare(_, state), do: {:ok, state}

  def handle_demand(:source, size, _unit, _, state) do
    {{:ok, demand: {:sink, size * 10}}, state}
  end

  def handle_event(:sink, %Membrane.Event{type: :eos}, _, state) do
    IO.inspect "EOS received"
    {:ok, %{state | eos: true }}
  end

  def handle_event(:sink, event, opts, state) do 
    IO.inspect {:eventreceived, event, opts }
    {:ok, state}
  end
  
  @doc false
  def handle_process1(:sink, %Buffer{payload: data} = buffer, _, %{native: native, queue: queue, eos: eos} = state) do
    to_encode = queue <> data
    with {:ok, {encoded_audio, bytes_used}} when bytes_used > 0
      <- encode_buffer(native, to_encode, state)
    do
      << _handled :: binary-size(bytes_used), rest :: binary >> = to_encode

      buffer = [ buffer: {:source, %Buffer{buffer | payload: encoded_audio}} ]
      event = if byte_size(rest) == 0 && eos do
        IO.inspect "EOS send"
        [ event: {:source, Membrane.Event.eos()}]
      else
        []
      end

      {{:ok, buffer ++ event}, %{ state | queue: rest }}
    else
      {:ok, {<<>>, 0}} -> {:ok, %{state | queue: to_encode}}
      {:error, reason} -> {{:error, reason}, state}
    end
  end

  # init
  defp encode_buffer(native, buffer, %{options: options} = state) do
    raw_frame_size = @samples_per_frame * @sample_size * options.channels
    encode_buffer(native, buffer, <<>>, 0, raw_frame_size, state[:eos])
  end

  # handle single frame
  defp encode_buffer(native, buffer, acc, bytes_used, raw_frame_size, is_eos)
  when byte_size(buffer) > raw_frame_size or is_eos do
    { raw_frame, rest } = case buffer do
      << used :: binary-size(raw_frame_size), rest :: binary >> -> {used, rest}
      << partial :: binary >> -> {partial, <<>>}
    end
    with {:ok, encoded_frame}
      <- EncoderNative.encode_frame(native, raw_frame)
    do
      encode_buffer(native, rest, acc <> encoded_frame, bytes_used + raw_frame_size, raw_frame_size, is_eos)
    else
      {:error, :buflen} ->
        {:ok, {acc, bytes_used}}

      {:error, reason} ->
        warn_error "Terminating stream because of malformed frame", reason
        {:error, reason}
    end
  end

  # Not enough samples for a frame
  defp encode_buffer(_native, _partial_buffer, acc, bytes_used, _raw_frame_size, false) do
    {:ok, {acc, bytes_used}}
  end
  
end
