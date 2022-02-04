#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <span>

using namespace std;

auto replace(string contents, const string& old_str, const string& new_str) -> string;
auto read_file(const string& file_name) -> string;
auto write_file(const string& file_name, const string& content)->bool;

struct Pair {
  string orig_str;
  string repl_str;
};

auto main(int argc, char **argv)->int {

  // Use span for safer c-array access
  span<char*> args{argv, size_t(argc)};

  // Check if there are enough arguments
  if (argc == 1) {
    cerr << "Error, not enough arguments.\n";
    cout << "Please launch with syntax:\nreplacer FILENAME ORIG_STRING1 "
      "REPLACEMENT_STRING1 ORIG_STRING2 REPLACEMENT_STRING2 ...\n";
    return 1;
  }

  auto* file_name{args[1]};

  // Check if asking for help
  if (file_name == string{"help"} || file_name == string{"--help"}) {
    cout << "Replacer. A program to replace all instances of a string in a file\n";
    cout << "Syntax:\nreplacer FILENAME ORIG_STRING1 "
      "REPLACEMENT_STRING1 ORIG_STRING2 REPLACEMENT_STRING2 ...\n";
    cout << "If FILENAME is a directory, replacer will recurse through the directory.";
    return 0;
  }

  // Create replacement pairs from given arguments
  vector<Pair> pairs{};
  for (int i{2}; i < (argc - 1); i += 2)
    pairs.push_back(Pair{args[i], args[i + 1]});

  string file_contents{read_file(file_name)};

  if (file_contents.empty()) {
    cerr << "Error reading file or file is empty.\n";
    return 1;
  }

  // Write existing contents to a backup file
  if (write_file(file_name + string{".bak"}, file_contents))
    cout << "\nSUCCESSFULLY BACKED UP FILE CONTENTS TO " << file_name
         << ".bak\n";
  else {
    cerr << "\nError backing up file contents.\n";
    return 1;
  }

  cout << "\nBEFORE REPLACEMENT\n\n";
  cout << file_contents;

  for (const auto &pair : pairs)
    file_contents = replace(file_contents, pair.orig_str, pair.repl_str);

  cout << "\nAFTER REPLACEMENT\n\n";
  cout << file_contents;

  if (write_file(file_name, file_contents))
    return 0;
  else {
    cerr << "Error writing file contents.\n";
    return 1;
  }
}

auto replace(string contents, const string& old_str, const string& new_str)->string {
  auto index{contents.find(old_str)};
  if (index != string::npos) {
    contents.erase(index, old_str.length());
    contents.insert(index, new_str);
    return replace(contents, old_str, new_str);
  } else
    return contents;
}

auto read_file(const string& file_name)->string {
  ifstream infile{file_name};
  string contents{};
  string tmp{};

  if (!infile)
    return "";

  while (infile) {
    getline(infile, tmp);
    contents += tmp + "\n";
  }

  // Correct extra space added to the end
  contents.erase(contents.length() - 2, 1);

  return contents;
}

auto write_file(const string& file_name, const string& content)->bool {
  ofstream outfile{file_name};

  if (!outfile)
    return false;

  outfile << content;
  return true;
}
