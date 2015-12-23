{
  'target_defaults': {
    'default_configuration': 'Release'
  },
  'targets': [
    {
      'target_name': 'scddetect',
      'type': 'executable',
      'sources': [
        'src/scddetect.c',
      ],
      'libraries': [
        '-L/app/vendor/libccv',
        '-lccv -lm -lpng -ljpeg -lpthread -lgsl -lgslcblas -lfftw3 -lfftw3f'
      ],
      'include_dirs': [
        '/usr/local/lib',
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
