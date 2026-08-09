import '../../data/models/cv_file_model.dart';

abstract class CvStates {}

class CvInitialState extends CvStates {}

class CvLoadingState extends CvStates {}

class GetCvFilesSuccessState extends CvStates {
  final List<CvFileModel> cvFiles;
  GetCvFilesSuccessState(this.cvFiles);
}

class UploadCvSuccessState extends CvStates {
  final CvFileModel cvFile;
  UploadCvSuccessState(this.cvFile);
}

class GetParsedDataSuccessState extends CvStates {
  final Map<String, dynamic> parsedData;
  GetParsedDataSuccessState(this.parsedData);
}

class GetSuggestionsSuccessState extends CvStates {
  final List<dynamic> suggestions;
  GetSuggestionsSuccessState(this.suggestions);
}

class CvActionSuccessState extends CvStates {
  final String message;
  CvActionSuccessState(this.message);
}

class CvErrorState extends CvStates {
  final String error;
  CvErrorState(this.error);
}
