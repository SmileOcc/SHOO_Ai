import '../domain/hos_music_track.dart';

abstract final class SHOMusicCatalog {
  static const demoTracks = <SHOMusicTrack>[
    SHOMusicTrack(
      id: 'demo_song_1',
      title: '晴天',
      artist: '周杰伦',
      album: '叶惠美',
      source: SHOMusicSource.network,
      coverColor: 0xFFE57373,
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      lrc: '''
[00:00.00]晴天 · 演示歌词
[00:12.00]故事的小黄花
[00:18.00]从出生那年就飘着
[00:24.00]童年的荡秋千
[00:30.00]随记忆一直晃到现在
[00:38.00]Re So So Si Do Si La
[00:44.00]So La Si Si Si La Si La So
[00:52.00]吹着前奏望着天空
[00:58.00]我想起花瓣试着掉落
[01:06.00]为你翘课的那一天
[01:12.00]花落的那一天
[01:18.00]教室的那一间
[01:24.00]我怎么看不见
[01:32.00]消失的下雨天
[01:38.00]我好想再淋一遍
[01:46.00]没想到失去的勇气我还留着
[01:54.00]好想再问一遍
[02:00.00]你会等待还是离开
''',
    ),
    SHOMusicTrack(
      id: 'demo_song_2',
      title: '稻香',
      artist: '周杰伦',
      album: '魔杰座',
      source: SHOMusicSource.network,
      coverColor: 0xFF81C784,
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      lrc: '''
[00:00.00]稻香 · 演示歌词
[00:10.00]对这个世界如果你有太多的抱怨
[00:18.00]跌倒了就不敢继续往前走
[00:26.00]为什么人要这么的脆弱 堕落
[00:34.00]请你打开电视看看
[00:40.00]多少人为生命在努力勇敢的走下去
[00:48.00]我们是不是该知足
[00:54.00]珍惜一切就算没有拥有
[01:02.00]还记得你说家是唯一的城堡
[01:10.00]随着稻香河流继续奔跑
[01:18.00]微微笑 小时候的梦我知道
[01:26.00]不要哭让萤火虫带着你逃跑
[01:34.00]乡间的歌谣永远的依靠
[01:42.00]回家吧 回到最初的美好
''',
    ),
    SHOMusicTrack(
      id: 'demo_song_3',
      title: '夜曲',
      artist: '周杰伦',
      album: '十一月的萧邦',
      source: SHOMusicSource.network,
      coverColor: 0xFF7986CB,
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      lrc: '''
[00:00.00]夜曲 · 演示歌词
[00:08.00]一群嗜血的蚂蚁
[00:14.00]被腐肉所吸引
[00:20.00]我面无表情
[00:26.00]看孤独的风景
[00:34.00]失去你 爱恨开始分明
[00:42.00]失去你 还有什么事好关心
[00:50.00]当鸽子不再象征和平
[00:56.00]我终于被提醒
[01:04.00]广场上喂食的是秃鹰
[01:12.00]我用漂亮的押韵
[01:18.00]形容被掠夺一空的爱情
[01:26.00]啊 乌云开始遮蔽
[01:32.00]夜色不干净
[01:40.00]公园里 葬礼的回音
[01:48.00]在漫天飞行
''',
    ),
  ];

  static SHOMusicTrack? findById(String id) {
    for (final track in demoTracks) {
      if (track.id == id) return track;
    }
    return null;
  }
}
