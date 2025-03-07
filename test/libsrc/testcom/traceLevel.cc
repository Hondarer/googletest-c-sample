#include <iostream>
#include <unordered_map>
#include <stdexcept>

#include <test_com.h>

using namespace std;
using namespace testing;

class TraceLevelDictionary
{
private:
    unordered_map<string, int> data;

    // コンストラクタを private にする (外部からのインスタンス化禁止)
    TraceLevelDictionary() {}

public:
    // シングルトンのインスタンスを取得
    static TraceLevelDictionary &getInstance()
    {
        static TraceLevelDictionary instance;
        return instance;
    }

    // コピー・ムーブを禁止
    TraceLevelDictionary(const TraceLevelDictionary &) = delete;
    TraceLevelDictionary &operator=(const TraceLevelDictionary &) = delete;

    // データをリセットする
    void clear()
    {
        data.clear();
    }

    // 値を更新または追加する
    void update(const string &key, int value)
    {
        data[key] = value;
    }

    // 値を取得する（キーが存在しない場合は 0 を返す）
    int get(const string &key) const
    {
        auto it = data.find(key);
        if (it == data.end())
        {
            return TRACE_NONE;
        }
        return it->second;
    }
};

void testing::clearTraceLevel()
{
    TraceLevelDictionary &dict = TraceLevelDictionary::getInstance();
    dict.clear();
}

int testing::_getTraceLevel(const char *key)
{
    TraceLevelDictionary &dict = TraceLevelDictionary::getInstance();
    return dict.get(key);
}

void testing::setTraceLevel(const char *key, int value)
{
    TraceLevelDictionary &dict = TraceLevelDictionary::getInstance();
    dict.update(key, value);
}
