extension StackTraceExtension on StackTrace {
  String? get callerFunctionName {
    // The trace comes with multiple lines of strings,
    // (each line is also known as a frame), so split the
    // trace's string by lines to get all the frames
    final frames = toString().split('\n');

    // The second frame is the caller function
    final frame = frames.elementAtOrNull(1);

    // null check
    if (frame == null) return null;

    // To get rid off the #number thing, get the index of the first whitespace
    var indexOfWhiteSpace = frame.indexOf(' ');

    // Create a substring from the first whitespace index till
    // the end of the string
    var subStr = frame.substring(indexOfWhiteSpace);

    // Grab the function name using reg expr
    final indexOfFunction = subStr.indexOf(RegExp(r'[A-Za-z0-9]'));

    // Create a new substring from the function name index till the
    // end of string
    subStr = subStr.substring(indexOfFunction);
    indexOfWhiteSpace = subStr.indexOf(' ');

    // Create a new substring from start to the first index of a whitespace.
    // This substring gives us the function name
    subStr = subStr.substring(0, indexOfWhiteSpace);

    return subStr;
  }
}