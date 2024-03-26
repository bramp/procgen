/// Returns true iff x and y are within epsilon of each other.
bool closeTo(double x, double y, {double epsilon = 1e-10}) {
  return (x - y).abs() < epsilon;
}
