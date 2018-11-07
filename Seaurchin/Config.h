#pragma once

#define ROOT_FILE(dir, fn) ((dir) + "/" + (fn))


#define SU_APP_NAME "Seaurchin"
#define SU_APP_VERSION "0.44.0"

#define SU_SETTING_FILE L"config.toml"
#define SU_CACHE_MUSIC_FILE L"musics.mp"
#define SU_NAMED_PIPE_NAME "\\\\.\\pipe\\seaurchin"

#define SU_DATA_DIR L"Data"
#define SU_IMAGE_DIR L"Images"
#define SU_SKIN_DIR L"Skins"
#define SU_FONT_DIR L"Fonts"
#define SU_CACHE_DIR L"Cache"
#define SU_CHARACTER_DIR L"Characters"
#define SU_MUSIC_DIR L"Music"
#define SU_SOUND_DIR L"Sounds"
#define SU_EXTENSION_DIR L"Extensions"
#define SU_SCRIPT_DIR L"Scripts"
#define SU_SKILL_DIR L"Skills"
#define SU_ABILITY_DIR L"Abilities"
#define SU_ICON_DIR L"Icons"

#define SU_SKIN_MAIN_FILE L"Skin.as"
#define SU_SKIN_TITLE_FILE L"Title.as"
#define SU_SKIN_SELECT_FILE L"Select.as"
#define SU_SKIN_PLAY_FILE L"Play.as"
#define SU_SKIN_RESULT_FILE L"Result.as"
#define SU_SYSTEM_MENU_FILE L"System.as"
#define SU_SETTING_DEFINITION_FILE L"SettingList.toml"

#define SU_FONT_SYSTEM "�l�r �S�V�b�N"

#define SU_RES_WIDTH 1280
#define SU_RES_HEIGHT 720

#define SU_EFX_PMAX 1024

//AngelScript��UserData�p
#define SU_UDTYPE_SCENE 100
#define SU_UDTYPE_WAIT 101
#define SU_UDTYPE_SKIN 102
#define SU_UDTYPE_ENTRYPOINT 103

// �J�X�^���E�B���h�E���b�Z�[�W

// Seaurchin�𗎂Ƃ�
// wp, lp: �Ȃ�
#define WM_SEAURCHIN_ABORT (WM_APP + 1)

// �Đ��J�n����
// wp, lp: �Ȃ�
// \\.\pipe\seaurchin �ɏ���̌`���Ńf�[�^�������o������
#define WM_SEAURCHIN_PLAY (WM_APP + 10)

// �����擾����
// wp, lp: �Ȃ�
#define WM_SEAURCHIN_GET_INFO (WM_APP + 11)