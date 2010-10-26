#ifndef __IMPLICIT_CAST_H__
#define __IMPLICIT_CAST_H__

namespace implicit_cast {

  const int degree2Radians = (3.14 / 180.0);
  const int radian2Degrees = (180.0 / 3.14);

  class Radian;

  class Degree
  {
    public:
      explicit Degree(float d) : val_(d) {}
      Degree(const Radian& r);

      float valueDegrees() const { return val_; }
      float valueRadians() const { return val_ * degree2Radians; }

    private:
      float val_;
  };

  class Radian
  {
    public:
      explicit Radian(float r) : val_(r) {} 
      Radian(const Degree& d) : val_(d.valueRadians()) {}

      float valueRadians() const { return val_; }
      float valueDegrees() const { return val_ * radian2Degrees; }

    private:
      float val_;
  };

  // Due to circular dependencies, need to define some
  // methods down here
  Degree::Degree(const Radian& r)
  {
    val_ = r.valueDegrees();
  }

  /**
   * And now some methods that work w/ the above two classes
   */
  bool isAcute(Degree degree) {
    return degree.valueDegrees() < 90;
  }

  bool isObtuse(Radian radian) {
    return radian.valueDegrees() > 90 && radian.valueDegrees() <= 180;
  }

  bool isRight(Degree* degree) {
    return degree->valueDegrees() == 90;
  }
}

#endif
