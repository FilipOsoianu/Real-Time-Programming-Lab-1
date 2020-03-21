defmodule Worker do
  use GenServer, restart: :permanent

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg)
  end

  # Callbacks 
  @impl true
  def init(msg) do
    # Logger.info("Starting #{inspect(name)}")
    # IO.inspect("start")
    IO.puts("start")

    # IO.inspect(json_parse(msg))
    {:ok, self()}
  end

  # @impl true
  # def handle_cast({:push, msg}, state) do
  #   # IO.inspect("push")
  #   data = json_parse(msg)
  #   # data = calc_mean(data)
  #   # frc = forecast(data)
  #   IO.inspect(msg)
  #   IO.puts("state")
  #   IO.inspect(state)
  #   {:noreply, [msg]}
  # end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    # Process.sleep(1000)
    IO.inspect(head)

    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, msg}, state) do
    # IO.inspect(msg)
    {:noreply, [msg | state]}
  end

  def json_parse(msg) do
    msg_data = Jason.decode!(msg.data)
    msg_data["message"]
  end

  defp calc_mean(data) do
    atmo_pressure_sensor_1 = data["atmo_pressure_sensor_1"]
    atmo_pressure_sensor_2 = data["atmo_pressure_sensor_2"]
    atmo_pressure_sensor = mean(atmo_pressure_sensor_1, atmo_pressure_sensor_2)
    humidity_sensor_1 = data["humidity_sensor_1"]
    humidity_sensor_2 = data["humidity_sensor_2"]
    humidity_sensor = mean(humidity_sensor_1, humidity_sensor_2)
    light_sensor_1 = data["light_sensor_1"]
    light_sensor_2 = data["light_sensor_2"]
    light_sensor = mean(light_sensor_1, light_sensor_2)
    temperature_sensor_1 = data["temperature_sensor_1"]
    temperature_sensor_2 = data["temperature_sensor_2"]
    temperature_sensor = mean(temperature_sensor_1, temperature_sensor_2)
    wind_speed_sensor_1 = data["wind_speed_sensor_1"]
    wind_speed_sensor_2 = data["wind_speed_sensor_2"]
    wind_speed_sensor = mean(wind_speed_sensor_1, wind_speed_sensor_2)
    unix_timestamp_us = data["unix_timestamp_us"]

    map = %{
      :atmo_pressure_sensor => atmo_pressure_sensor,
      :humidity_sensor => humidity_sensor,
      :light_sensor => light_sensor,
      :temperature_sensor => temperature_sensor,
      :wind_speed_sensor => wind_speed_sensor,
      :unix_timestamp_us => unix_timestamp_us
    }

    map
  end

  defp forecast(data) do
    cond do
      data[:temperature_sensor] < -2 && data[:light_sensor] < 128 &&
          data[:atmo_pressure_sensor] < 720 ->
        "SNOW"

      data[:temperature_sensor] < -2 && data[:light_sensor] > 128 &&
          data[:atmo_pressure_sensor] < 680 ->
        "WET_SNOW"

      data[:temperature_sensor] < -8 ->
        "SNOW"

      data[:temperature_sensor] < -15 && data[:wind_speed_sensor] > 45 ->
        "BLIZZARD"

      data[:temperature_sensor] > 0 && data[:atmo_pressure_sensor] < 710 &&
        data[:humidity_sensor] > 70 &&
          data[:wind_speed_sensor] < 20 ->
        "SLIGHT_RAIN"

      data[:temperature_sensor] > 0 && data[:atmo_pressure_sensor] < 690 &&
        data[:humidity_sensor] > 70 &&
          data[:wind_speed_sensor] > 20 ->
        "HEAVY_RAIN"

      data[:temperature_sensor] > 30 && data[:atmo_pressure_sensor] < 770 &&
        data[:humidity_sensor] > 80 &&
          data[:light_sensor] > 192 ->
        "HOT"

      data[:temperature_sensor] > 30 && data[:atmo_pressure_sensor] < 770 &&
        data[:humidity_sensor] > 50 &&
        data[:light_sensor] > 192 && data[:wind_speed_sensor] > 35 ->
        "CONVECTION_OVEN"

      data[:temperature_sensor] > 25 && data[:atmo_pressure_sensor] < 750 &&
        data[:humidity_sensor] > 70 &&
        data[:light_sensor] < 192 && data[:wind_speed_sensor] < 10 ->
        "CONVECTION_OVEN"

      data[:temperature_sensor] > 25 && data[:atmo_pressure_sensor] < 750 &&
        data[:humidity_sensor] > 70 &&
        data[:light_sensor] < 192 && data[:wind_speed_sensor] > 10 ->
        "SLIGHT_BREEZE"

      data[:light_sensor] < 128 ->
        "CLOUDY"

      data[:temperature_sensor] > 30 && data[:atmo_pressure_sensor] < 660 &&
        data[:humidity_sensor] > 85 &&
          data[:wind_speed_sensor] > 45 ->
        "MONSOON"

      true ->
        "JUST_A_NORMAL_DAY"
    end
  end

  defp mean(a, b) do
    a + b / 2
  end
end