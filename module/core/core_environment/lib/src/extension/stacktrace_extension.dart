extension StackTraceExtension on StackTrace {
  CustomTrace get traces => CustomTrace(this);
}

class CustomTrace {

  late final String fileName;
  late final String functionName;
  late final String callerFunctionName;
  late final int lineNumber;
  late final int columnNumber;

  CustomTrace(StackTrace trace) {
    // The trace comes with multiple lines of strings,
    // (each line is also known as a frame), so split the
    // trace's string by lines to get all the frames
    final frames = trace.toString().split('\n');

    // The first frame is the current function
    functionName = _getFunctionNameFromFrame(frames[0]);

    // The second frame is the caller function
    callerFunctionName = _getFunctionNameFromFrame(frames[1]);

    // The first frame has all the information we need
    final traceString = frames[0];

    // Search through the string and find the index of the file name by
    // looking for the '.dart' regex
    final indexOfFileName = traceString.indexOf(RegExp(r'[A-Za-z]+.dart'));
    final fileInfo = traceString.substring(indexOfFileName);
    var listOfInfos = fileInfo.split(':');

    /*
      Splitting fileInfo by the character ":" separates the file name,
      the line number and the column counter nicely.

      Example: main.dart:5:12
      To get the file name, we split with ":" and get the first index
      To get the line number, we would have to get the second index
      To get the column number, we would have to get the third index
    */
    fileName = listOfInfos[0];
    lineNumber = int.parse(listOfInfos[1]);

    var columnStr = listOfInfos[2];
    columnStr = columnStr.replaceFirst(')', '');
    columnNumber = int.parse(columnStr);
  }

  String _getFunctionNameFromFrame(String frame) {
    // Just giving another nickname to the frame
    final currentTrace = frame;

    // To get rid off the #number thing, get the index of the first whitespace
    var indexOfWhiteSpace = currentTrace.indexOf(' ');

    // Create a substring from the first whitespace index till
    // the end of the string
    var subStr = currentTrace.substring(indexOfWhiteSpace);

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