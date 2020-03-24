defmodule Aggregator do
  use GenServer, restart: :permanent

  def start_link(forecast) do
    Process.sleep(1000)
    GenServer.start_link(__MODULE__, forecast, name: __MODULE__)
  end

  @impl true
  def init(_forecast) do
    start_time = Time.utc_now()
    final_forecast = "JUST_A_NORMAL_DAY"
    forecast_list = []

    state = %{
      time: start_time,
      sensor_value_list: %{
        temperature_sensor: [],
        humidity_sensor: [],
        atmo_pressure_sensor: [],
        wind_speed_sensor: [],
        light_sensor: []
      },
      final_sensor_value: %{},
      forecast: final_forecast,
      forecast_list: forecast_list
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_forecast, _from, state) do
    response = state
    start_time = Time.utc_now()
    final_forecast = "JUST_A_NORMAL_DAY"
    forecast_list = []

    state = %{
      time: start_time,
      sensor_value_list: %{
        temperature_sensor: [],
        humidity_sensor: [],
        atmo_pressure_sensor: [],
        wind_speed_sensor: [],
        light_sensor: []
      },
      final_sensor_value: %{},
      forecast: final_forecast,
      forecast_list: forecast_list
    }

    {:reply, response, state}
  end

  @impl true
  def handle_cast({:forecast, forecast, current_senors_value}, state) do
    start_time = state[:time]
    sensor_value_list = state[:sensor_value_list]
    final_sensor_value = state[:final_sensor_value]
    forecast_list = state[:forecast_list]
    final_forecast = state[:final_forecast]

    state = %{
      time: start_time,
      forecast: final_forecast,
      forecast_list: [forecast | forecast_list],
      final_sensor_value: final_sensor_value,
      sensor_value_list: add_value_in_map(sensor_value_list, current_senors_value)
    }

    {:noreply, state}
  end

  def add_value_in_map(map_of_list, map_of_values) do
    map =
      Enum.reduce(map_of_list, map_of_list, fn {k, v}, acc ->
        value = map_of_values[k]
        v = [value | v]
        Map.put(acc, k, v)
      end)

    map
  end
end
