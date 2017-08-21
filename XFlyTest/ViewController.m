//
//  ViewController.m
//  XFlyTest
//
//  Created by 王涛 on 2017/8/16.
//  Copyright © 2017年 王涛. All rights reserved.
//

#import "ViewController.h"
#import "iflyMSC/IFlyMSC.h"

#define NAME        @"userwords"
#define USERWORDS   @"{\"userword\":[{\"name\":\"我的常用词\",\"words\":[\"佳晨实业\",\"蜀南庭苑\",\"高兰路\",\"复联二\"]},{\"name\":\"我的好友\",\"words\":[\"李馨琪\",\"鹿晓雷\",\"张集栋\",\"周家莉\",\"叶震珂\",\"熊泽萌\"]}]}"

@interface ViewController ()<IFlySpeechRecognizerDelegate>
//不带界面的识别对象
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic, strong) IFlyDataUploader *uploader;//数据上传对象
@property (nonatomic, strong) NSString * result;
@property (nonatomic, strong) UILabel *resultlabel;


@property (nonatomic, strong) NSString             * cloudGrammerid;//云端在线识别生成的grammarID
@property (nonatomic, strong) NSString             * localgrammerId;//本地识别生成的grammarID

@property (nonatomic, strong) NSMutableString      * curResult;//当前session的结果
@property (nonatomic)         BOOL                  isCanceled;

@property (nonatomic)         NSString             * engineType;//引擎类型
@property (nonatomic)         NSString             * grammarType;//语法类型
@property (nonatomic, strong) NSArray              * engineTypes;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 100, 50);
    button.center = self.view.center;
    [button setTitle:@"开始识别" forState:UIControlStateNormal];
    [button setTitle:@"正在识别" forState:UIControlStateSelected];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _resultlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 300, 200, 60)];
    _resultlabel.text = @"识别结果:";
    _resultlabel.textColor = [UIColor blackColor];
    [self.view addSubview:_resultlabel];
}

- (void)buttonAction:(UIButton *)sender {
    
    UIButton *buttom = sender;
    buttom.selected = !buttom.selected;
    if (buttom.selected) {
        //创建语音识别对象
        //设置音频来源为麦克风
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //设置听写结果格式为json
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        _iFlySpeechRecognizer.delegate = self;
        //设置识别参数
        //设置为听写模式
        [_iFlySpeechRecognizer setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
        //asr_audio_path 是录音文件名，设置value为nil或者为空取消保存，默认保存目录在Library/cache下。
        [_iFlySpeechRecognizer setParameter:@"iat.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        //启动识别服务
        [_iFlySpeechRecognizer startListening];
        _resultlabel.text = @"识别结果:";
    }else {
        [_iFlySpeechRecognizer stopListening];
    }
}


//普通语音识别
- (void)dictation {
    //        //创建语音识别对象
    //        //设置音频来源为麦克风
    //        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    //
    //        //设置听写结果格式为json
    //        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    //
    //        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    //        _iFlySpeechRecognizer.delegate = self;
    //        //设置识别参数
    //        //设置为听写模式
    //        [_iFlySpeechRecognizer setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
    //        //asr_audio_path 是录音文件名，设置value为nil或者为空取消保存，默认保存目录在Library/cache下。
    //        [_iFlySpeechRecognizer setParameter:@"iat.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    //        //启动识别服务
}

- (void)keywords {
    
    [_iFlySpeechRecognizer stopListening];
    [_uploader setParameter:@"iat" forKey:[IFlySpeechConstant SUBJECT]];
    [_uploader setParameter:@"userword" forKey:[IFlySpeechConstant DATA_TYPE]];

    IFlyUserWords *iFlyUserWords = [[IFlyUserWords alloc] initWithJson:USERWORDS ];

    [_uploader uploadDataWithCompletionHandler:
     ^(NSString * grammerID, IFlySpeechError *error)
     {
         if (error.errorCode == 0) {
             _resultlabel.text = @"佳晨实业\n蜀南庭苑\n高兰路\n复联二\n李馨琪\n鹿晓雷\n张集栋\n周家莉\n叶震珂\n熊泽萌\n";
         }
     } name:NAME data:[iFlyUserWords toString]];
}

#pragma mark - IFlySpeechRecognizerDelegate

//识别结果返回代理
- (void)onResults:(NSArray *)results isLast:(BOOL)isLast {

    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSLog(@"dic:%@",dic);
   NSString * resultFromJson =  [self stringFromJson:resultString];
   
    _resultlabel.text = [NSString stringWithFormat:@"%@%@",_resultlabel.text,resultFromJson];

     NSLog(@"resultFromJson:%@",_resultlabel.text);
}
//识别会话结束返回代理
- (void)onError:(IFlySpeechError *)error {
    
}
//停止录音回调
- (void)onEndOfSpeech {

}
//开始录音回调
- (void)onBeginOfSpeech {

}
//音量回调函数
- (void)onVolumeChanged:(int)volume {

    NSLog(@"volume:%d",volume);
}
//会话取消回调
- (void)onCancel {


}

- (NSString *)stringFromJson:(NSString*)params
{
    if (params == NULL) {
        return nil;
    }
    
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:    //返回的格式必须为utf8的,否则发生未知错误
                                [params dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    if (resultDic!= nil) {
        NSArray *wordArray = [resultDic objectForKey:@"ws"];
        
        for (int i = 0; i < [wordArray count]; i++) {
            NSDictionary *wsDic = [wordArray objectAtIndex: i];
            NSArray *cwArray = [wsDic objectForKey:@"cw"];
            
            for (int j = 0; j < [cwArray count]; j++) {
                NSDictionary *wDic = [cwArray objectAtIndex:j];
                NSString *str = [wDic objectForKey:@"w"];
                [tempStr appendString: str];
            }
        }
    }
    return tempStr;
}


#pragma mark - ----------------------------------------------
#pragma mark - Button handler

/*
 *****文件读取*****
 */
- (NSString *)readFile:(NSString *)filePath {
    NSData *reader = [NSData dataWithContentsOfFile:filePath];
    return [[NSString alloc] initWithData:reader
                                 encoding:NSUTF8StringEncoding];
}

- (BOOL)createDirec:(NSString *) direcName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *subDirectory = [documentsDirectory stringByAppendingPathComponent:direcName];
    BOOL ret = YES;
    if(![fileManager fileExistsAtPath:subDirectory])
    {
        // 创建目录
        ret = [fileManager createDirectoryAtPath:subDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return ret;
}

- (void)buildGrammer {
    _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    _iFlySpeechRecognizer.delegate = self;
    NSString *grammarContent = nil;
    NSString *documentsPath = nil;
    NSArray *appArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([appArray count] > 0) {
        documentsPath = [appArray objectAtIndex:0];
    }
    NSString *appPath = [[NSBundle mainBundle] resourcePath];
    [self createDirec:@"grm"];
    self.engineType = [IFlySpeechConstant TYPE_LOCAL];
    if([self.engineType isEqualToString:[IFlySpeechConstant TYPE_LOCAL]])
    {
        //grammar build path
        NSString *grammBuildPath = [documentsPath stringByAppendingString:@"/grm"];
        
        //aitalk resource path
        NSString *aitalkResourcePath = [[NSString alloc] initWithFormat:@"%@/aitalkResource/common.mp3",appPath];
        //bnf resource
        NSString *bnfFilePath = [[NSString alloc] initWithFormat:@"%@/data/bnf/search.bnf",appPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:bnfFilePath]) {
            NSLog(@"bnfFilePath存在");
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:aitalkResourcePath]) {
            NSLog(@"aitalkResourcePath存在");
        }
        
        grammarContent = [self readFile:bnfFilePath];
        
        [[IFlySpeechUtility getUtility] setParameter:@"asr" forKey:[IFlyResourceUtil ENGINE_START]];
        
        [_iFlySpeechRecognizer setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
        [_iFlySpeechRecognizer setParameter:self.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
        
        [_iFlySpeechRecognizer setParameter:grammBuildPath forKey:[IFlyResourceUtil GRM_BUILD_PATH]];
        
        [_iFlySpeechRecognizer setParameter:aitalkResourcePath forKey:[IFlyResourceUtil ASR_RES_PATH]];
        [self.iFlySpeechRecognizer setParameter:@"asr" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        [_iFlySpeechRecognizer setParameter:@"utf-8" forKey:@"result_encoding"];
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    }else {
        //        [_iFlySpeechRecognizer setParameter:self.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
        //        [_iFlySpeechRecognizer setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
        //        [self.iFlySpeechRecognizer setParameter:@"asr" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        //        //bnf resource
        //        NSString *bnfFilePath = [[NSString alloc] initWithFormat:@"%@/bnf/grammar_sample.abnf",appPath];
        //        grammarContent = [self readFile:bnfFilePath];
    }
    
    //开始构建
    [_iFlySpeechRecognizer buildGrammarCompletionHandler:^(NSString * grammerID, IFlySpeechError *error){
        if (![error errorCode]) {
            NSLog(@"上传成功");
        }
        else {
            NSLog(@"errorCode=%d",[error errorCode]);
            NSLog(@"上传失败");
        }
        
        if ([self.engineType isEqualToString: [IFlySpeechConstant TYPE_LOCAL]]) {
            _localgrammerId = grammerID;
            [_iFlySpeechRecognizer setParameter:_localgrammerId  forKey:[IFlySpeechConstant LOCAL_GRAMMAR]];
        }
        else{
            _cloudGrammerid = grammerID;
            //设置grammarid
            [_iFlySpeechRecognizer setParameter:_cloudGrammerid forKey:[IFlySpeechConstant CLOUD_GRAMMAR]];
        }
        
    }grammarType:@"bnf" grammarContent:grammarContent];
}


@end
