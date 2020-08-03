run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file save_row copy_column");

IMAGE_DIRECTORY_PATH = "/path/to/images/";
IMAGE_LIST = getFileList(IMAGE_DIRECTORY_PATH);
HEADERS = newArray("zwarte_prut", "witte_prut");
CSV_FILE_NAME = "science_stuff";
FILE_EXTENSION = ".csv";
RESULT_BLACK = newArray("zwarte_prut");
RESULT_WHITE = newArray("witte_prut");
FILE_NAME_TITLE = "Filename";

FULL_FILE_NAME = IMAGE_DIRECTORY_PATH + CSV_FILE_NAME + FILE_EXTENSION;

if (File.exists(FULL_FILE_NAME) == true) {
  exit(FULL_FILE_NAME + ' already exists, please remove or rename to not cause any conflicts.');
  Table.showRowNumbers(false);
} else if (IMAGE_LIST.length == 0) { 
  exit('No images to process were found at ' + IMAGE_DIRECTORY_PATH);
}

for (i = 0; i < IMAGE_LIST.length; i++) {
  open(IMAGE_DIRECTORY_PATH + IMAGE_LIST[i]);
  run("8-bit");

  setAutoThreshold("Default dark");
  setOption("BlackBackground", true);
  run("Convert to Mask", "method=Default background=Dark calculate black");


  getHistogram(values, counts, HEADERS.length);
  run("Close");
  RESULT_BLACK = appendToArray(RESULT_BLACK, counts[0]);
  RESULT_WHITE = appendToArray(RESULT_WHITE, counts[1]);
}

FILE_NAMES = unshiftToArray(FILE_NAME_TITLE, IMAGE_LIST);

Table.setColumn(FILE_NAMES[0], FILE_NAMES);
Table.setColumn(RESULT_BLACK[0], RESULT_BLACK);
Table.setColumn(RESULT_WHITE[0], RESULT_WHITE);
updateResults();

Table.save(FULL_FILE_NAME);
selectWindow("Results");
run("Close");
exit("Done processing " + IMAGE_LIST.length + " image(s)");

function appendToArray(arr, value) {
  arr2 = newArray(arr.length + 1);
  for (i = 0; i < arr.length; i++)
    arr2[i] = arr[i];
  arr2[arr.length] = value;
  return arr2;
}

function unshiftToArray(str, arr2) {
  newArrayTemp = newArray(1 + arr2.length);
  newArrayTemp[0] = str;
  for (i = 1; i <= arr2.length; i++) {
    newArrayTemp[i] = arr2[i - 1];
  }
  return newArrayTemp;
}