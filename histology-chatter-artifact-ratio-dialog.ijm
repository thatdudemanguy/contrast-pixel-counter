
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file save_row copy_column");

// Defaults
// absolute path
IMAGE_DIRECTORY_PATH = "/path/to/images/";
// export file name
CSV_FILE_NAME = "science_stuff";
// black spots
RESULT_BLACK = "zwarte_prut";
// white spots
RESULT_WHITE = "witte_prut";
// file name title
FILE_NAME_TITLE = "Filename";
// default slider value
DEFAULT_SLIDER_VALUE = 247;
// SLIDER LABEL
SLIDER_LABEL_MIN = "Threshold: min";
// SLIDER LABEL
SLIDER_LABEL_MAX = "Threshold: max";

Dialog.create("Hello there");
Dialog.addMessage("This macro was created by Robin Van Roy - github.com/thatdudemanguy");
Dialog.addMessage("To start, please select the first image of your sequence");
Dialog.show();

path = File.openDialog("Select the first file");
IMAGE_DIRECTORY_PATH = File.getParent(path);

Dialog.create("Histology chatter artifact ratio");
Dialog.addString("Image location path", IMAGE_DIRECTORY_PATH);
Dialog.addString("File name column header", FILE_NAME_TITLE);
Dialog.addString("Name - blacks", RESULT_BLACK);
Dialog.addString("Name - whites", RESULT_WHITE);
Dialog.addString("Export filename", CSV_FILE_NAME);
Dialog.addSlider(SLIDER_LABEL_MIN, 0, 250, 0);
Dialog.addSlider(SLIDER_LABEL_MAX, 0, 250, DEFAULT_SLIDER_VALUE);
Dialog.addChoice("Export type:", newArray(".csv"));
Dialog.show();

// Don't touch
IMAGE_DIRECTORY_PATH = Dialog.getString();

if(!matches(IMAGE_DIRECTORY_PATH, "/\/$/g")) {
  IMAGE_DIRECTORY_PATH = IMAGE_DIRECTORY_PATH + '/';
}

FILE_NAME_TITLE = Dialog.getString();
RESULT_BLACK = newArray(Dialog.getString());
RESULT_WHITE = newArray(Dialog.getString());
CSV_FILE_NAME = Dialog.getString();
THRESHOLD_MIN = Dialog.getNumber();
THRESHOLD_MAX = Dialog.getNumber();
FILE_EXTENSION = Dialog.getChoice();

IMAGE_LIST = getFileList(IMAGE_DIRECTORY_PATH);
FULL_FILE_NAME = IMAGE_DIRECTORY_PATH + CSV_FILE_NAME + FILE_EXTENSION;

// if file exists -> throw notification
if (File.exists(FULL_FILE_NAME) == true) {
  exit(FULL_FILE_NAME + ' already exists, please remove or rename to not cause any conflicts.');
  Table.showRowNumbers(false);
} else if (IMAGE_LIST.length == 0) {
  // else if no images found -> throw notification
  exit('No images to process were found at ' + IMAGE_DIRECTORY_PATH);
}

// loop through all images found
for (i = 0; i < IMAGE_LIST.length; i++) {
  // open one image
  open(IMAGE_DIRECTORY_PATH + IMAGE_LIST[i]);
  // run 8 bit
  run("8-bit");

  // define thresholds
  // setAutoThreshold("Default dark");
  setThreshold(THRESHOLD_MIN, THRESHOLD_MAX);
  setOption("BlackBackground", true);
  run("Convert to Mask", "method=Default background=Dark calculate black");

  // run histogram
  getHistogram(values, counts, 2);
  // close histogram
  run("Close");
  // push results to array
  RESULT_BLACK = appendToArray(RESULT_BLACK, counts[0]);
  RESULT_WHITE = appendToArray(RESULT_WHITE, counts[1]);
}

// unshift to array
FILE_NAMES = unshiftToArray(FILE_NAME_TITLE, IMAGE_LIST);

// set values to table out of loop
Table.setColumn(FILE_NAMES[0], FILE_NAMES);
Table.setColumn(RESULT_BLACK[0], RESULT_BLACK);
Table.setColumn(RESULT_WHITE[0], RESULT_WHITE);
updateResults();

// save to csv
Table.save(FULL_FILE_NAME);
// open results
selectWindow("Results");
run("Close");
// show notification -> done
exit("Done processing " + IMAGE_LIST.length + " image(s)");

// custom append to array function, because the macro language doesn't support push()
function appendToArray(arr, value) {
  arr2 = newArray(arr.length + 1);
  for (i = 0; i < arr.length; i++)
    arr2[i] = arr[i];
  arr2[arr.length] = value;
  return arr2;
}

// custom append to array function, because the macro language doesn't support unshift()
function unshiftToArray(str, arr2) {
  newArrayTemp = newArray(1 + arr2.length);
  newArrayTemp[0] = str;
  for (i = 1; i <= arr2.length; i++) {
    newArrayTemp[i] = arr2[i - 1];
  }
  return newArrayTemp;
}