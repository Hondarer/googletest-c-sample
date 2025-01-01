#include <test_com.h>

AssertionResult FileExists(const string &file_path)
{
    struct stat buffer;
    if (stat(file_path.c_str(), &buffer) == 0)
    {
        return AssertionSuccess();
    }
    else
    {
        return AssertionFailure() << "File " << file_path << " does not exist.";
    }
}

AssertionResult FileNotExists(const string &file_path)
{
    struct stat buffer;
    if (stat(file_path.c_str(), &buffer) != 0)
    {
        return AssertionSuccess();
    }
    else
    {
        return AssertionFailure() << "File " << file_path << " does exist.";
    }
}

AssertionResult FileContains(const string &file_path, const string &expected_content)
{
    ifstream file(file_path);
    if (!file.is_open())
    {
        return AssertionFailure() << "File " << file_path << " does not exist.";
    }

    string line;
    while (getline(file, line))
    {
        if (line.find(expected_content) != string::npos)
        {
            cout << "String \"" << expected_content << "\" found in file " << file_path << ", \"" << line << "\"" << endl;
            return AssertionSuccess();
        }
    }

    return AssertionFailure() << "String \"" << expected_content << "\" not found in file " << file_path;
}
