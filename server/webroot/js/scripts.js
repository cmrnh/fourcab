$(document).ready(function()
{
	var top = $('#download').offset().top;
	var height = 0;

	$(document).scroll(function()
	{
		if(top > $(document).scrollTop()) $('#download').removeClass('fixedView');
		else if($('#download').offset().top < $(document).scrollTop()) $('#download').addClass('fixedView');
	});

});
