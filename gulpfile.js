const gulp  = require('gulp');
const butternut = require('gulp-butternut');
const coffee = require('gulp-coffee');
const mocha = require('gulp-mocha');

gulp.task('coffee', () =>
  gulp.src('./src/*.coffee')
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest('./target/'))
);

gulp.task('compress', ['coffee'], () =>
  /* Currently broken ...
  gulp
    .src('./target/*.js')
    .pipe(butternut({file: 'default.js'}))
    .pipe(gulp.dest('./Contents/Scripts/'))
  */
  gulp
    .src('./target/*.js')
    .pipe(gulp.dest('./Contents/Scripts/'))
);

gulp.task('test', ['compress'], () =>
    gulp
      .src('./test/*.coffee', {read: false})
      .pipe(mocha({reporter: 'spec', compilers: 'coffee:coffee-script/register'}))
);

gulp.task('watch', () =>
  gulp
    .watch('./src/*.coffee', ['default'])
);

gulp.task('default', [ 'coffee', 'test', 'compress' ]);

