const gulp  = require('gulp');
const uglify = require('gulp-uglify');
const pump = require('pump');
const coffee = require('gulp-coffee');
const mocha = require('gulp-mocha');

gulp.task('coffee', () =>
  gulp.src('./src/*.coffee')
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest('./target/'))
);

gulp.task('test', ['coffee'], () =>
    gulp
      .src('./test/*.coffee', {read: false})
      .pipe(mocha({reporter: 'spec', compilers: 'coffee:coffee-script/register'}))
);

gulp.task('compress', ['test'], () =>
  pump([
      gulp.src('./target/*.js'),
      uglify(),
      gulp.dest('./Contents/Scripts/')
  ])
);

gulp.task('default', ['compress']);

