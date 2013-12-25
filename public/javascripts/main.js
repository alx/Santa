$(function(){

  $('.randomOpeningCode').click(function() {
    $(this).parents('form-group').find('input').val(Math.floor(Math.random() * 10000).toPrecision(4));
  });

});
