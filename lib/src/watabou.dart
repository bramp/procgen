import 'dart:math';

// TODO Figure out if we need this.
num watabouPow(num x, num exponent) {
  if (x > 0) {
    return pow(x, exponent);
  } else {
    return -pow(-x, exponent);
  }
}
