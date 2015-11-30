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
        '/home/vilson/repos/ccv/lib/libccv.a -lm -lcblas -latlas -lpng -ljpeg -lfftw3 -lfftw3f -lpthread -lavcodec -lavformat -lswscale -lgsl -lgslcblas'
      ],
      'include_dirs': [
        '/home/vilson/repos/ccv/lib'
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
