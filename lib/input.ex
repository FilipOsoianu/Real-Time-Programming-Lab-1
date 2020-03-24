defmodule Input do
  def start_link do
    time_now = Time.utc_now()
    update_frequency = 1000
    pid = spawn_link(__MODULE__, :get_input, [time_now, update_frequency])
    {:ok, pid}
  end

  def get_input(start_time, update_frequency) do
    user_input = IO.gets("")
    if user_input === "t\n" do
      update_frequency =
        IO.gets("Introduce forcast update time: ")
        |> String.trim("\n")
        |> Integer.parse()
        |> elem(0)

      get_forecast(start_time, update_frequency)
    else
      get_forecast(start_time, update_frequency)
    end

  end

  def get_forecast(start_time, update_frequency) do
    time_now = Time.utc_now()
    diff = Time.diff(time_now, start_time, :millisecond)

    if diff > update_frequency do
      received_forecast = GenServer.call(Aggregator, :get_forecast)
      forecast_list = received_forecast[:forecast_list]
      sensor_value_list = received_forecast[:sensor_value_list]

      final_forecast = most_frequent(forecast_list)
      final_sensor_value = get_average_value(sensor_value_list)
      print(final_forecast, final_sensor_value)
      get_input(time_now, update_frequency)
    else
      get_input(start_time, update_frequency)
    end
  end

  def get_average_value(map_of_list) do
    avgList =
      Enum.map(map_of_list, fn {key, val} ->
        {key, [Enum.reduce(val, fn score, sum -> sum + score end) / Enum.count(val)]}
      end)

    map = Enum.into(avgList, %{})

    Enum.reduce(map, map, fn {k, v}, acc ->
      [head | _tail] = v
      Map.put(acc, k, head)
    end)
  end

  def most_frequent(list) do
    map = Enum.frequencies(list)
    map = Enum.sort(map, fn {_k, v}, {_k1, v1} -> v > v1 end)
    tuple = Enum.at(map, 0)
    list = Tuple.to_list(tuple)
    List.first(list)
  end

  def print(forecast, sensor_value) do
    IO.puts("<------------------------------->")
    IO.puts("Forecast")
    IO.inspect(forecast)
    IO.puts("Atmosphere pressure ")
    IO.inspect(sensor_value[:atmo_pressure_sensor])
    IO.puts("Humidity")
    IO.inspect(sensor_value[:humidity_sensor])
    IO.puts("Light")
    IO.inspect(sensor_value[:light_sensor])
    IO.puts("Temperature")
    IO.inspect(sensor_value[:temperature_sensor])
    IO.puts("Wind speed")
    IO.inspect(sensor_value[:wind_speed_sensor])
    IO.puts("<------------------------------->")
  end
end
