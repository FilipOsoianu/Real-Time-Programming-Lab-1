defmodule Aggregator do
  use GenServer, restart: :permanent

  def start_link(forecast) do
    GenServer.start_link(__MODULE__, forecast)
  end

  @impl true
  def init(forecast) do

    {:ok, forecast}
  end

  @impl true
  def handle_cast({:forecast, forecast, current_senors_value}, state) do
    IO.inspect(forecast)
    # IO.inspect(data)
    # start_time = state[:start_time]
    # current_time = Time.utc_now()

    # state = %{:time: start_time, :final_weather %{}, :mean_weather %{}, :final_sensors_value %{}, :mean_sensors_value %{}}


    # current_weater = forecast
    # mean_weater = state[:mean_weather]
    # final_weather = state[:final_weather]
    
    # final_sensors_value = state[:final_sensors_value] 
    # mean_sensors_value = state[:mean_sensors_value] 
    # current_senors_value = current_senors_value


    # final_wind_speed_sensor = final_weather[:final_wind_speed_sensor]
    # final_temperature_sensor = final_weather[:final_temperature_sensor]
    # final_light_sensor = final_weather[:final_light_sensor]
    # final_humidity_sensor = final_weather[:final_humidity_sensor]
    # final_atmo_pressure_sensor = final_weather[:final_atmo_pressure_sensor]


    # current_wind_speed_sensor = data[:wind_speed_sensor]
    # current_temperature_sensor = data[:temperature_sensor]
    # current_light_sensor = data[:light_sensor]
    # current_humidity_sensor = data[:humidity_sensor]
    # current_atmo_pressure_sensor = data[:atmo_pressure_sensor]


    # mean_wind_speed_sensor = mean_sensors_value[:mean_wind_speed_sensor]
    # mean_temperature_sensor = mean_sensors_value[:mean_temperature_sensor]
    # mean_light_sensor = mean_sensors_value[:mean_light_sensor]
    # mean_humidity_sensor = mean_sensors_value[:mean_humidity_sensor]
    # mean_atmo_pressure_sensor = mean_sensors_value[:mean_atmo_pressure_sensor]



    {:noreply, []}
  end




  # @impl true
  # def handle_call(:get_forecast, _from, state) do
  #   {:reply, get_data_flow(state[:current_flow]), state}
  # end

  # @impl true
  # def handle_cast(:send_flow, state) do
  #   counter = state[:counter]

  #   time_now = Time.utc_now()
  #   diff = Time.diff(time_now, start_time, :millisecond)

  #   if diff > 1000 do
  #     current_flow = counter
  #     counter = 0
  #     state = %{counter: counter, start_time: time_now, current_flow: current_flow}
  #     {:noreply, state}
  #   else
  #     counter = counter + 1
  #     state = %{counter: counter, start_time: start_time, current_flow: current_flow}
  #     {:noreply, state}
  #   end
  # end

end
