{
  'target_defaults': {
    'default_configuration': 'Release'
  },
  'targets': [
    {
      'target_name': 'scddetect',
      'type': 'executable',
      'sources': [
        'src/scddetect.c'
      ],
      'libraries': [
        '-L/app/vendor/libccv',
        '-L/home/travis/libccv',
        '-lccv -lm -lpng -ljpeg -lpthread'
      ],
      'include_dirs': [
        '/usr/local/lib',
        '/home/travis/libccv',
        '/app/vendor/libccv'
      ],
      'conditions': [
        ['OS=="mac"', {
          'xcode_settings': {
            'GCC_ENABLE_CPP_EXCEPTIONS': 'YES',
            'OTHER_CFLAGS': [
              '-g',
              '-mmacosx-version-min=10.7',
              '-std=c++11',
              '-stdlib=libc++',
              '-O3',
              '-Wall'
            ],
            'OTHER_CPLUSPLUSFLAGS': [
              '-g',
              '-mmacosx-version-min=10.7',
              '-std=c++11',
              '-stdlib=libc++',
              '-O3',
              '-Wall'
            ]
          }
        }]
      ]
    },
    {
      'target_name': 'swtdetect',
      'type': 'executable',
      'sources': [
        'src/swtdetect.c'
      ],
      'libraries': [
        '-L/app/vendor/libccv',
        '-L/home/travis/libccv',
        '-lccv -lm -lpng -ljpeg -lpthread'
      ],
      'include_dirs': [
        '/usr/local/lib',
        '/home/travis/libccv',
        '/app/vendor/libccv'
      ],
      'conditions': [
        ['OS=="mac"', {
          'xcode_settings': {
            'GCC_ENABLE_CPP_EXCEPTIONS': 'YES',
            'OTHER_CFLAGS': [
              '-g',
              '-mmacosx-version-min=10.7',
              '-std=c++11',
              '-stdlib=libc++',
              '-O3',
              '-Wall'
            ],
            'OTHER_CPLUSPLUSFLAGS': [
              '-g',
              '-mmacosx-version-min=10.7',
              '-std=c++11',
              '-stdlib=libc++',
              '-O3',
              '-Wall'
            ]
          }
        }]
      ]
    }
  ]
}
