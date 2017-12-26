[EntryPoint]
class Play : CoroutineScene {
  Skin@ skin;
  Image@ imgWhite;
  Image@ imgGCEmpty, imgGCFull, imgGBBack, imgGBFill, imgGBFront;
  Font@ font32, font64, fontLatin;
  ScenePlayer@ player;
  CharacterInfo charinfo;
  
  void Initialize() {
    LoadResources();
    ExecuteScene(charinfo);
  }
  
  void Run() {
    RunCoroutine(Coroutine(RunPlayer), "Player:RunPlayer");
    RunCoroutine(Coroutine(Main), "Player:Main");
    RunCoroutine(Coroutine(KeyInput), "Player:KeyInput");
    YieldTime(1);
    while(true) YieldTime(30);
  }
  
  void Draw() {
    
  }
  
  void LoadResources() {
    @skin = GetSkin();
    @fontLatin = skin.GetFont("Latin128");
    @font32 = skin.GetFont("Normal32");
    @font64 = skin.GetFont("Normal64");
    @imgWhite = skin.GetImage("TitleBack");
    @imgGCEmpty = skin.GetImage("GaugeCountEmpty");
    @imgGCFull = skin.GetImage("GaugeCountFull");
    @imgGBBack = skin.GetImage("GaugeBarBack");
    @imgGBFill = skin.GetImage("GaugeBarFill");
    @imgGBFront = skin.GetImage("GaugeBarFront");
  }
  
  void SetPlayerResource() {
    player.SetResource("LaneGround", skin.GetImage("*Lane-Ground"));
    player.SetResource("LaneJudgeLine", skin.GetImage("*Lane-JudgeLine"));
    player.SetResource("LaneHoldLight", skin.GetImage("*Lane-HoldLight"));
    player.SetResource("FontCombo", font64);
    player.SetResource("Tap", skin.GetImage("*Note-Tap"));
    player.SetResource("ExTap", skin.GetImage("*Note-ExTap"));
    player.SetResource("AirUp", skin.GetImage("*Note-AirUp"));
    player.SetResource("AirDown", skin.GetImage("*Note-AirDown"));
    player.SetResource("Flick", skin.GetImage("*Note-Flick"));
    player.SetResource("HellTap", skin.GetImage("*Note-HellTap"));
    player.SetResource("Hold", skin.GetImage("*Note-Hold"));
    player.SetResource("HoldStrut", skin.GetImage("*Note-HoldStrut"));
    player.SetResource("Slide", skin.GetImage("*Note-Slide"));
    player.SetResource("SlideStrut", skin.GetImage("*Note-SlideStrut"));
    player.SetResource("AirAction", skin.GetImage("*Note-AirAction"));
    player.SetResource("SoundTap", skin.GetSound("*Sound-Tap"));
    player.SetResource("SoundExTap", skin.GetSound("*Sound-ExTap"));
    player.SetResource("SoundFlick", skin.GetSound("*Sound-Flick"));
    player.SetResource("SoundAir", skin.GetSound("*Sound-Air"));
    player.SetResource("SoundAirAction", skin.GetSound("*Sound-AirAction"));
    player.SetResource("SoundHoldLoop", skin.GetSound("*Sound-SlideLoop"));
    player.SetResource("SoundSlideLoop", skin.GetSound("*Sound-HoldLoop"));
    player.SetResource("EffectTap", skin.GetAnime("*Anime-Tap"));
    player.SetResource("EffectExTap", skin.GetAnime("*Anime-ExTap"));
    player.SetResource("EffectAirAction", skin.GetAnime("*Anime-AirAction"));
    player.SetResource("EffectSlideTap", skin.GetAnime("*Anime-SlideTap"));
    player.SetResource("EffectSlideLoop", skin.GetAnime("*Anime-SlideLoop"));
  }
  
  void RunPlayer() {
    @player = ScenePlayer();
    SetPlayerResource();
    player.Initialize();
    player.Z = 5;
    AddSprite(player);
    player.Load();
    while(!player.IsLoadCompleted()) YieldFrame(1);
    SetMusicInfo();
    Fire("Player:Ready");
    YieldTime(5);
    player.Play();
  }
  
  Sprite@ spTopCover, spBack;
  array<Sprite@> spGaugeCounts(10);
  Sprite@ spBarBack, spBarFront;
  ClipSprite@ spBarFill;
  TextSprite@ txtScore, txtMaxCombo, txtScoreInfo, txtMaxComboInfo;
  TextSprite@ txtTitle, txtArtist, txtLevel;
  SynthSprite@ spJudges, spJacket;
  void Main() {
    @spBack = Sprite(skin.GetImage("TitleBack"));
    @spTopCover = Sprite(skin.GetImage("PlayerTopCover"));
    spTopCover.Apply("z:10");
    // スコアなど
    @txtMaxCombo = TextSprite(font64, "0");
    txtMaxCombo.Apply("x:630, y:8, scaleX: 0.6, scaleY: 0.6, z:15");
    txtMaxCombo.SetAlignment(TextAlign::Right, TextAlign::Top);
    
    @txtMaxComboInfo = TextSprite(font64, "Max Combo");
    txtMaxComboInfo.Apply("x:390, y:10, scaleX: 0.5, scaleY: 0.5, z:15");
    
    @txtScore = TextSprite(font64, "0");
    txtScore.Apply("x:890, y:8, scaleX: 0.6, scaleY: 0.6, z:15");
    txtScore.SetAlignment(TextAlign::Right, TextAlign::Top);
    
    @txtScoreInfo = TextSprite(font64, "Score");
    txtScoreInfo.Apply("x:650, y:10, scaleX: 0.5, scaleY: 0.5, z:15");
    
    @txtLevel = TextSprite(font64, "");
    txtLevel.Apply("x:1276, y: -8, z: 15");
    txtLevel.SetAlignment(TextAlign::Right, TextAlign::Top);
    
    @txtTitle = TextSprite(font64, "");
    txtTitle.Apply("x:1008, y: 26, z: 151");
    txtTitle.SetRangeScroll(240, 20, 32);
    
    @txtArtist = TextSprite(font32, "");
    txtArtist.Apply("x: 1008, y: 74, z: 15");
    txtTitle.SetRangeScroll(240, 20, 32);
    
    @spJacket = SynthSprite(640, 640);
    spJacket.Apply("x: 908, y: 4, z: 15, scaleX: 0.15, scaleY: 0.15");
    
    @spJudges = SynthSprite(768, 24);
    spJudges.Transfer(skin.GetImage("JudgeJC"), 0, 0);
    spJudges.Transfer(skin.GetImage("JudgeJ"), 192, 0);
    spJudges.Transfer(skin.GetImage("JudgeA"), 416, 0);
    spJudges.Transfer(skin.GetImage("JudgeM"), 564, 0);
    array<TextSprite@> spCounts = {
      TextSprite(font32, "0"),
      TextSprite(font32, "0"),
      TextSprite(font32, "0"),
      TextSprite(font32, "0")
    };
    spCounts[0].Apply("x: 520, y: -3, scaleX: 0.8, scaleY: 0.6, z: 15");
    spCounts[1].Apply("x: 650, y: -3, scaleX: 0.8, scaleY: 0.6, z: 15");
    spCounts[2].Apply("x: 790, y: -3, scaleX: 0.8, scaleY: 0.6, z: 15");
    spCounts[3].Apply("x: 888, y: -3, scaleX: 0.8, scaleY: 0.6, z: 15");
    spJudges.Apply("x:640, y:0, z:15, scaleX: 0.6666, scaleY: 0.58, origX: 384");
    for(int i = 0; i < 4; i++) spCounts[i].SetAlignment(TextAlign::Right, TextAlign::Top);
    // ゲージ
    for(int i = 0; i < 10; i++) {
      @spGaugeCounts[i] = Sprite(imgGCEmpty);
      spGaugeCounts[i].Apply("x:" + (384 + i * 32) + ", y:90, z:11, scaleX:0.5, scaleY:0.3");
      AddSprite(spGaugeCounts[i]);
    }
    @spBarBack = Sprite(imgGBBack);
    @spBarFront = Sprite(imgGBFront);
    @spBarFill = ClipSprite(512, 64);
    spBarFill.Transfer(imgGBFill, 0, 0);
    spBarFill.SetRange(0, 0, 0, 1);
    spBarBack.Apply("x:384, y:40, z:15, scaleY: 0.75");
    spBarFill.Apply("x:384, y:40, z:16, scaleY: 0.75");
    spBarFront.Apply("x:384, y:40, z:17, scaleY: 0.75");
    
    AddSprite(spBack);
    AddSprite(spTopCover);
    AddSprite(txtMaxCombo);
    AddSprite(txtScore);
    AddSprite(txtMaxComboInfo);
    AddSprite(txtScoreInfo);
    AddSprite(txtTitle);
    AddSprite(txtArtist);
    AddSprite(txtLevel);
    AddSprite(spJacket);
    AddSprite(spJudges);
    for(int i = 0; i < 4; i++) AddSprite(spCounts[i]);
    AddSprite(spBack);
    AddSprite(spBarBack);
    AddSprite(spBarFill);
    AddSprite(spBarFront);
    
    DrawableResult dsNow, dsPrev;
    while(true) {
      player.GetCurrentResult(dsNow);
      if (dsNow.FulfilledGauges > dsPrev.FulfilledGauges) for(int i = dsPrev.FulfilledGauges; i < dsNow.FulfilledGauges; i++) {
         spGaugeCounts[i].SetImage(imgGCFull);
         spGaugeCounts[i].Apply("scaleX:0.8");
         spGaugeCounts[i].AddMove("scale_to(x:0.5, y:0.3, time:0.3)");
      }
      if (dsNow.CurrentGaugeRatio != dsPrev.CurrentGaugeRatio) {
        spBarFill.AddMove("range_size(width:" + formatFloat(dsNow.CurrentGaugeRatio, '', 1, 4) + ", height:1, time:0.1, ease:out_sine)");
        txtScore.SetText(formatInt(dsNow.Score, "", 8));
      }
      if (dsNow.MaxCombo != dsPrev.MaxCombo) txtMaxCombo.SetText(formatInt(dsNow.MaxCombo, "", 5));
      
      spCounts[0].SetText("" + dsNow.JusticeCritical);
      spCounts[1].SetText("" + dsNow.Justice);
      spCounts[2].SetText("" + dsNow.Attack);
      spCounts[3].SetText("" + dsNow.Miss);
      dsPrev = dsNow;
      YieldFrame(1);
    }
  }
  
  void SetMusicInfo() {
    Image@ jacket = Image(GetStringData("Player:Jacket"));
    spJacket.Transfer(jacket, 0, 0);
    txtTitle.SetText(GetStringData("Player:Title"));
    txtArtist.SetText(GetStringData("Player:Artist"));
    txtLevel.SetText("" + GetIntData("Player:Level"));
  }
  
  bool isPausing;
  void KeyInput() {
    while(true) {
      if (IsKeyTriggered(Key::INPUT_ESCAPE)) {
        if (Execute("Select.as")) {
          Fire("Player:End");
          Disappear();
        }
      }
      if (IsKeyTriggered(Key::INPUT_LEFT)) {
        player.MovePositionByMeasure(-1);
      }
      if (IsKeyTriggered(Key::INPUT_RIGHT)) {
        player.MovePositionByMeasure(1);
      }
      if (IsKeyTriggered(Key::INPUT_SPACE)) {
        if (isPausing) {
          player.Resume();
        } else {
          player.Pause();
        }
        isPausing = !isPausing;
      }
      if (IsKeyTriggered(Key::INPUT_R) && IsKeyHeld(Key::INPUT_LCONTROL)) {
        player.Reload();
      }
      
      YieldFrame(1);
    }
  }
}

class CharacterInfo : CoroutineScene {
  Skin@ skin;
  
  void Initialize() {
    @skin = GetSkin();
    InitInfo();
    InitReady();
  }
  
  SynthSprite@ spInfo;
  void InitInfo() {
    CharacterManager@ cm = GetCharacterManager();
    
    @spInfo = SynthSprite(314, 302);
    spInfo.Transfer(skin.GetImage("CharacterBack"), 0, 0);
    spInfo.Transfer(Image(cm.GetImagePath(0)), 8, 6);
    
    TextSprite @spDescription = TextSprite(skin.GetFont("Normal32"), "");
    spDescription.Apply("x:20, y: 166, r: 0, g: 0, b: 0");
    spDescription.SetText(cm.GetDescription(0));
    spDescription.SetRich(true);
    spInfo.Transfer(spDescription);
    
    spInfo.Apply("x:-314, y: 110, z:30");
    AddSprite(spInfo);
  }
  
  Sprite@ spReadyBack, spReadyFront;
  TextSprite@ spReady;
  void InitReady() {
    @spReadyBack = Sprite(skin.GetImage("Ready1"));
    spReadyBack.Apply("origX:640, origY:72, x:640, y:360, z:40, scaleY:0");
    
    @spReadyFront = Sprite(skin.GetImage("Ready2"));
    spReadyFront.Apply("origY:72, x:-1280, y:360, z:41");
    
    @spReady = TextSprite(skin.GetFont("Normal64"), "ARE YOU READY?");
    spReady.SetAlignment(TextAlign::Center, TextAlign::Center);
    spReady.Apply("x:640, y:360, z:41, scaleX:0");
    
    AddSprite(spReadyBack);
    AddSprite(spReadyFront);
    AddSprite(spReady);
  }
  
  void ReadyString() {
    spReady.AddMove("scale_to(x:1.4, y:1.4, time:0.3, wait:0.7, ease:out_back)");
    spReady.AddMove("scale_to(x:1.4, y:0, time:0.1, wait:2.0, ease:out_sine)");
    YieldTime(2.1);
    spReady.SetText("START!");
    spReady.AddMove("scale_to(x:1.4, y:1.4, time:0.3, wait:0.7, ease:out_back)");
    spReady.AddMove("scale_to(x:4, y:1.4, time:0.5, wait:2, ease:out_sine)");
    spReady.AddMove("alpha(x:1, y:0, time:0.5, wait:2)");
    spReady.AddMove("death(wait:2.5)");
  }
  
  void Run() {
    while(true) YieldFrame(100);
  }
  
  void Draw() {
    
  }
  
  void OnEvent(const string &in event) {
    if (event == "Player:End") Disappear();
    if (event == "Player:Ready") {
      spInfo.AddMove("move_by(x:314, time:0.5, ease:out_quad)");
      spReadyBack.AddMove("scale_to(x:1, y:1, time:0.3, ease:out_sine)");
      spReadyFront.AddMove("move_by(x:1280, time:0.5, wait:0.3, ease:out_sine)");
      RunCoroutine(Coroutine(ReadyString), "CharInfo:Ready");
      // 4.1秒後にフェードアウト開始
      spReadyBack.AddMove("scale_to(x:1, y:0, time:0.3, wait:4.1, ease:in_back)");
      spReadyFront.AddMove("alpha(x:1, y:0, time:0.3, wait:4.1)");
      spReadyBack.AddMove("death(wait:4.4)");
      spReadyFront.AddMove("death(wait:4.4)");
    }
  }
}