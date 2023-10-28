class WeatherData{
  //variables
  final double temp;
  
  //constructor
  const WeatherData({
    required this.temp,
  });

  //methods
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temp: json['main']['temp'].toDouble(),
    );
  }

}