defmodule Aggregator do
  use GenServer, restart: :permanent

  def start_link(forecast) do
    GenServer.start_link(__MODULE__, forecast)
  end

  @impl true
  def init(_forecast) do
    start_time = Time.utc_now()
    final_forecast = "JUST_A_NORMAL_DAY"
    forecast_list = []

    state = %{
      time: start_time,
      final_sensors_value: %{},
      mean_sensors_value: %{},
      forecast: final_forecast,
      forecast_list: forecast_list
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_forecast, _from, state) do
    forecast = %{
      forecast: state[:forecast],
      temperature_sensor: state[:final_sensors_value][:temperature_sensor],
      humidity_sensor: state[:final_sensors_value][:humidity_sensor],
      atmo_pressure_sensor: state[:final_sensors_value][:atmo_pressure_sensor],
      wind_speed_sensor: state[:final_sensors_value][:wind_speed_sensor],
      light_sensor: state[:final_sensors_value][:light_sensor]
    }

    {:reply, forecast, state}
  end

  @impl true
  def handle_cast({:forecast, forecast, current_senors_value}, state) do
    start_time = state[:time]
    time_now = Time.utc_now()

    diff = Time.diff(time_now, start_time, :millisecond)

    final_sensors_value = state[:final_sensors_value]
    mean_sensors_value = state[:mean_sensors_value]
    forecast_list = state[:forecast_list]
    final_forecast = state[:final_forecast]

    if diff > 1000 do
      final_sensors_value = mean_sensors_value
      final_forecast = most_common(forecast_list)
      forcecast_list = []

      state = %{
        time: time_now,
        final_sensors_value: final_sensors_value,
        mean_sensors_value: mean_sensors_value,
        forecast: final_forecast,
        forecast_list: forcecast_list
      }
      IO.puts("<------------------------------->")
      IO.puts("Forecast")
      IO.inspect(state[:forecast])
      IO.puts("Atmosphere pressure ")
      IO.inspect(state[:final_sensors_value][:atmo_pressure_sensor])
      IO.puts("Humidity")
      IO.inspect(state[:final_sensors_value][:humidity_sensor])
      IO.puts("Light")
      IO.inspect(state[:final_sensors_value][:light_sensor])
      IO.puts("Temperature")
      IO.inspect(state[:final_sensors_value][:temperature_sensor])
      IO.puts("Wind speed")
      IO.inspect(state[:final_sensors_value][:wind_speed_sensor])
      IO.puts("<------------------------------->")

      {:noreply, state}
    else
      mean_sensors_value = get_sensor_mean_value(mean_sensors_value, current_senors_value)

      state = %{
        time: start_time,
        final_sensors_value: final_sensors_value,
        mean_sensors_value: mean_sensors_value,
        forecast: final_forecast,
        forecast_list: [forecast | forecast_list]
      }

      {:noreply, state}
    end
  end

  def most_common(list) do
    map = Enum.frequencies(list)
    list_values = Map.values(map)
    max_value = Enum.max(list_values)

    forecast =
      Enum.map(map, fn {k, v} ->
        if v == max_value do
          k
        end
      end)

    [head | _tail] = Enum.filter(forecast, &(!is_nil(&1)))
    head
  end

  def get_sensor_mean_value(current_sensors_value_map, mean_sensors_value_map) do
    Map.merge(current_sensors_value_map, mean_sensors_value_map, fn _k, v1, v2 ->
      (v1 + v2) / 2
    end)
  end
end
