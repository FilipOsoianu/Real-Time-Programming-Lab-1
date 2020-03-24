defmodule Input do
  def start_link do
    time_now = Time.utc_now()
    update_frequency = 1000
    spawn_link(__MODULE__, :get_input, [time_now, update_frequency])
    forecast_pid = spawn_link(__MODULE__, :get_forecast, [time_now, update_frequency, true])
    :ets.new(:buckets_registry, [:named_table])

    :ets.insert(:buckets_registry, {"forecast_pid", forecast_pid})
    {:ok, self()}
  end

  def get_input(start_time, update_frequency) do
    [{_id, forecast_pid}] = :ets.lookup(:buckets_registry, "forecast_pid")
    user_input = IO.gets("")

    if user_input === "t\n" do
      send(forecast_pid, [false | update_frequency])

      update_frequency =
        IO.gets("Introduce forcast update time: ")
        |> String.trim("\n")
        |> Integer.parse()
        |> elem(0)

      send(forecast_pid, [true | update_frequency])
      get_input(start_time, update_frequency)
    else
      get_input(start_time, update_frequency)
    end
  end

  def get_forecast(start_time, update_frequency, is_working) do
    time_now = Time.utc_now()
    diff = Time.diff(time_now, start_time, :millisecond)

    if diff > update_frequency && is_working === true do
      forecast = GenServer.call(Aggregator, :get_forecast)
      print(forecast)
      get_forecast(time_now, update_frequency, is_working)
    else
      receive do
        [is_working | update_frequency] ->
            get_forecast(start_time, update_frequency, is_working)
      after
        10 -> get_forecast(start_time, update_frequency, is_working)
      end
    end
  end

  def print(forecast) do
    IO.puts("<------------------------------->")
    IO.puts("Forecast")
    IO.inspect(forecast[:final_forecast])
    IO.puts("Atmosphere pressure ")
    IO.inspect(forecast[:final_sensor_value][:atmo_pressure_sensor])
    IO.puts("Humidity")
    IO.inspect(forecast[:final_sensor_value][:humidity_sensor])
    IO.puts("Light")
    IO.inspect(forecast[:final_sensor_value][:light_sensor])
    IO.puts("Temperature")
    IO.inspect(forecast[:final_sensor_value][:temperature_sensor])
    IO.puts("Wind speed")
    IO.inspect(forecast[:final_sensor_value][:wind_speed_sensor])
    IO.puts("<------------------------------->")
  end
end
