const gulp  = require('gulp');
const butternut = require('gulp-butternut');
const coffee = require('gulp-coffee');
const mocha = require('gulp-mocha');

gulp.task('coffee', function() {
  gulp.src('./src/*.coffee')
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest('./target/'));
});

gulp.task('compress', function (cb) {
  gulp.src('./target/*.js')
    .pipe(butternut({file: 'default.js'}))
    .pipe(gulp.dest('Contents/Scripts'));
});

gulp.task('test', () =>
    gulp
      .src('./test/*.coffee', {read: false})
      .pipe(mocha({reporter: 'spec', compilers: 'coffee:coffee-script/register'}))
);

gulp.task('default', [ 'coffee', 'test', 'compress' ]);

