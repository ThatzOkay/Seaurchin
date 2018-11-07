#pragma once

#define SU_NOTE_LONG_MASK  0b00000000001110000000
#define SU_NOTE_SHORT_MASK 0b00000000000001111110

enum class SusNoteType : uint16_t {
	Undefined = 0,

    // �V���[�g
    Tap,            // Tap
    ExTap,          // ExTap
	Flick,          // Flick
	Air,            // Air
    HellTap,        // AIR: Hell Tap
    AwesomeExTap,   // STAR PLUS: ��ׁ[ExTap (https://twitter.com/chunithm/status/967959264055648256)

    // �����O
    Hold = 7,       // Hold
    Slide,          // Slide
	AirAction,      // AirAction

    // �ʒu(�����O�p)
    Start = 10,     // �J�n
    Step,           // ���p
	Control,        // �ϋ�
    End,            // �I��

    // ����(Air�p�A�g�ݍ��킹��)
    Up = 14,        // ��
    Down,           // ��
    Left,           // ��
    Right,          // �E

    // ���̑�
    Injection = 18, // (�����O)�R���{�}��
    Invisible,      // �s��
    MeasureLine,    // ���ߐ�
    Grounded,       // Air�̑����ʂɕ`�悳���
    StartPosition,  // ���[�����ł̊J�n�ʒu(�I���Q�L�p)
};

struct SusRelativeNoteTime {
    uint32_t Measure;
    uint32_t Tick;

    bool operator<(const SusRelativeNoteTime& b) const
    {
        return Measure < b.Measure || Tick < b.Tick;
    }
    bool operator>(const SusRelativeNoteTime& b) const
    {
        return Measure > b.Measure || Tick > b.Tick;
    }
    bool operator==(const SusRelativeNoteTime& b) const
    {
        return Measure == b.Measure && Tick == b.Tick;
    }
    bool operator!=(const SusRelativeNoteTime& b) const
    {
        return Measure != b.Measure || Tick != b.Tick;
    }
};


struct SusHispeedData {
    enum class Visibility {
        Keep = -1,
        Invisible,
        Visible,
    };
    const static double keepSpeed;

    Visibility VisibilityState = Visibility::Visible;
    double Speed = 1.0;

};

class SusHispeedTimeline final {
private:
    std::vector<std::pair<SusRelativeNoteTime, SusHispeedData>> keys;
    std::vector<std::tuple<double, double, SusHispeedData>> data;
    std::function<double(uint32_t, uint32_t)> relToAbs;

public:
    SusHispeedTimeline(std::function<double(uint32_t, uint32_t)> func);
    void AddKeysByString(const std::string &def, const std::function<std::shared_ptr<SusHispeedTimeline>(uint32_t)>&
                         resolver);
    void AddKeyByData(uint32_t meas, uint32_t tick, double hs);
    void AddKeyByData(uint32_t meas, uint32_t tick, bool vis);
    void Finialize();
    std::tuple<bool, double> GetRawDrawStateAt(double time);
    double GetSpeedAt(double time);
};

class SusNoteExtraAttribute final {
public:
    uint32_t Priority = 0;
    int32_t RollHispeedNumber = -1;
    std::shared_ptr<SusHispeedTimeline> RollTimeline = nullptr;
    double HeightScale = 1.0;

    void Apply(const std::string &props);
};

enum class SusMetaDataFlags : uint16_t {
    DisableMetronome,
    EnableDrawPriority,
    EnableMovingLane,
};

struct SusMetaData {
    std::string UTitle = u8"";
    std::string USubTitle = u8"";
    std::string UArtist = u8"";
    std::string UJacketFileName = u8"";
    std::string UDesigner = u8"";
    std::string USongId = u8"";
    std::string UWaveFileName = u8"";
    std::string UBackgroundFileName = u8"";
    std::string UMovieFileName = u8"";
    double WaveOffset = 0;
    double MovieOffset = 0;
    double BaseBpm = 0;
    double ShowBpm = -1;
    double ScoreDuration = 0;
    int SegmentsPerSecond = 20;
    uint32_t Level = 0;
    uint32_t DifficultyType = 0;
    std::string UExtraDifficulty = "";
    std::bitset<8> ExtraFlags;

    void Reset()
    {
        USongId = "";
        UTitle = USubTitle = u8"";
        UArtist = UDesigner = u8"";
        UJacketFileName = UWaveFileName = UBackgroundFileName = "";
        WaveOffset = 0;
        BaseBpm = 0;
        Level = 0;
        ShowBpm = -1;
        ScoreDuration = 0;
        SegmentsPerSecond = 100;
        DifficultyType = 0;
        UExtraDifficulty = u8"";
        ExtraFlags.reset();
    }
};

struct SusRawNoteData {
    std::bitset<32> Type;
    std::shared_ptr<SusHispeedTimeline> Timeline;
    union {
        uint16_t DefinitionNumber;
        struct {
            uint8_t StartLane;
            uint8_t Length;
        } NotePosition;
    };
    uint8_t Extra;
    std::shared_ptr<SusNoteExtraAttribute> ExtraAttribute;
    
    bool operator==(const SusRawNoteData& b) const
    {
        if (Type != b.Type) return false;
        if (Timeline != b.Timeline) return false;
        if (DefinitionNumber != b.DefinitionNumber) return false;
        if (Extra != b.Extra) return false;
        if (ExtraAttribute != b.ExtraAttribute) return false;
        return true;
    }
    bool operator!=(const SusRawNoteData& b) const
    {
        return !(*this == b);
    }
};

struct SusDrawableNoteData {
    std::bitset<32> Type;
    std::bitset<8> OnTheFlyData;
    std::shared_ptr<SusHispeedTimeline> Timeline;
    std::shared_ptr<SusNoteExtraAttribute> ExtraAttribute;
    uint8_t StartLane = 0;
    uint8_t Length = 0;
    float CenterAtZero = 0;

    //���`��ʒu
    double ModifiedPosition = 0;
    double StartTimeEx = 0;
    double DurationEx = 0;
    //�`��"�n�߂�"����
    double StartTime = 0;
    //�`�悪"����"����
    double Duration = 0;
    //�X���C�h�EAA�p����f�[�^
    std::vector<std::shared_ptr<SusDrawableNoteData>> ExtraData;

    std::tuple<bool, double> GetStateAt(double time);
};


using DrawableNotesList = std::vector<std::shared_ptr<SusDrawableNoteData>>;
using NoteCurvesList = std::unordered_map<std::shared_ptr<SusDrawableNoteData>, std::vector<std::tuple<double, double>>>;

// BMS�h���t�H�[�}�b�g����SUS(SeaUrchinScore)�̉��
class SusAnalyzer final {
private:
    static boost::xpressive::sregex regexSusCommand;
    static boost::xpressive::sregex regexSusData;

    double defaultBeats = 4.0;
    double defaultBpm = 120.0;
    uint32_t defaultHispeedNumber = std::numeric_limits<uint32_t>::max();
    uint32_t defaultExtraAttributeNumber = std::numeric_limits<uint32_t>::max();
    uint32_t ticksPerBeat;
    uint32_t measureCountOffset;
    double longInjectionPerBeat;
    std::function<std::shared_ptr<SusHispeedTimeline>(uint32_t)> timelineResolver = nullptr;
    std::vector<std::function<void(std::string, std::string)>> errorCallbacks;
    std::vector<std::tuple<SusRelativeNoteTime, SusRawNoteData>> notes;
    std::vector<std::tuple<SusRelativeNoteTime, SusRawNoteData>> bpmChanges;
    std::unordered_map<uint32_t, double> bpmDefinitions;
	std::unordered_map<uint32_t, float> beatsDefinitions;
    std::unordered_map<uint32_t, std::shared_ptr<SusHispeedTimeline>> hispeedDefinitions;
    std::shared_ptr<SusHispeedTimeline> hispeedToApply, hispeedToMeasure;
    std::unordered_map<uint32_t, std::shared_ptr<SusNoteExtraAttribute>> extraAttributes;
    std::shared_ptr<SusNoteExtraAttribute> extraAttributeToApply;

    void ProcessCommand(const boost::xpressive::smatch &result, bool onlyMeta, uint32_t line);
    void ProcessRequest(const std::string &cmd, uint32_t line);
    void ProcessData(const boost::xpressive::smatch &result, uint32_t line);
    void MakeMessage(uint32_t line, const std::string &message);
    void MakeMessage(uint32_t meas, uint32_t tick, uint32_t lane, const std::string &message);
    void CalculateCurves(const std::shared_ptr<SusDrawableNoteData>& note, NoteCurvesList &curveData) const;

public:
    SusMetaData SharedMetaData;
    std::vector<std::tuple<double, double>> SharedBpmChanges;

    explicit SusAnalyzer(uint32_t tpb);
    ~SusAnalyzer();

    void Reset();
    void SetMessageCallBack(const std::function<void(std::string, std::string)>& func);
    void LoadFromFile(const std::wstring &fileName, bool analyzeOnlyMetaData = false);
    void RenderScoreData(DrawableNotesList &data, NoteCurvesList &curveData);
    float GetBeatsAt(uint32_t measure);
    double GetBpmAt(uint32_t measure, uint32_t tick);
    double GetAbsoluteTime(uint32_t meas, uint32_t tick);
    std::tuple<uint32_t, uint32_t> GetRelativeTime(double time);
    uint32_t GetRelativeTicks(uint32_t measure, uint32_t tick);
};