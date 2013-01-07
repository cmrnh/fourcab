/**
 * slideshow class!
 * 
 * @param Object	options - customize your slideshow
 * @option Number	fadeTime - the time in milliseconds in between 2 pics
 * @option Number	fadeSpeed - the time in milliseconds for the fade animation (or one of these pre-defined values: 'fast', 'normal', 'slow')
 * @option Object	hookPrevious - JQuery object to hook to 'previous'
 * @option Object	hookNext - JQuery object to hook to 'next'
 * @option Array	images - array of paths to images for slideshow
 * @option Array	links - array of urls for the visible image to link to in case of click
 * @option boolean	random - show images in random order
 * @option preload	Number - set how many images to preload (0 = all)
 * 
 * @author Matthias Mullie <matthias@netlash.com>
 */

$.extend($.fn,
{
	slideshow: function (options)
	{
		return this.each(function()
		{
			// create object
			var slideshow =
			{
				/**
				 * slideshow variables
				 */
				defaults:
				{
					fadeTime : 5000,
					fadeSpeed : 'normal',
					hookPrevious : null,
					hookNext : null,
					hookSpecific : new Array(),
					images : new Array(),
					links : new Array(),
					random : false,
					preload : 2
				},

				element : null,
				elementNext : null,
				elementCurr : null,
				imagesArray : new Array(),
				currentImage : -1, // when random, this one will actually be the next image's id, so we can preload that one
				timer : 0,

				/**
				 * fade images in/out
				 */
				fade : function()
				{
					// not random, go to next (or previous) image
					if (!slideshow.options.random || slideshow.currentImage == -1)
					{
						if (arguments.length == 0 || arguments[0] === true)	slideshow.currentImage++;
						else
						{
							if (arguments[0] === false)						slideshow.currentImage--;
							else											slideshow.currentImage = parseInt(arguments[0]);
						}
					}

					// boundaries doublecheck
					if (slideshow.currentImage > slideshow.options.images.length - 1)	slideshow.currentImage = 0;
					else if (slideshow.currentImage < 0)								slideshow.currentImage = slideshow.options.images.length - 1;

					// check if image has already preloaded
					if (slideshow.imagesArray[slideshow.currentImage])
					{
						if (slideshow.imagesArray[slideshow.currentImage].complete)
						{
							// prepare new image in the back
							slideshow.elementNext.attr('src', slideshow.options.images[slideshow.currentImage]);

							// this will be overwritten when random, however we may still need it (for links)
							var currentImage = slideshow.currentImage;

							// fade out current img & move new image to the front and make that img visible again
							slideshow.elementCurr.fadeOut(slideshow.options.fadeSpeed, function()
							{
								slideshow.elementCurr.attr('src', slideshow.elementNext.attr('src'));
								setTimeout(function() { slideshow.elementCurr.show(); }, 50); // timeout makes sure the slow IE6 js engine can keep up :)

								// unbind possible bound click event (can't keep adding click event handlers, do we? :) )
								slideshow.elementCurr.unbind('click');

								// check if we have a link for this image
								if (slideshow.options.links[currentImage])
								{
									slideshow.elementCurr.css('cursor', 'pointer');
									slideshow.elementCurr.click(function() { window.location = slideshow.options.links[currentImage]; return false; }); // make sure we unbind this
								}
								else slideshow.elementCurr.css('cursor', 'default');
							});

							// let's have our next image in <fadeTime>
							slideshow.timer = setTimeout(function() { slideshow.fade(); }, slideshow.options.fadeTime);

							// random? pick the next image already so we can preload it
							if (slideshow.options.random)
							{
								// do not pick the same image as the one currently shown
								do var random = Math.floor(Math.random() * slideshow.options.images.length);
								while (random == slideshow.currentImage);
								slideshow.currentImage = random;
							}
						}

						// img not yet loaded, try again in 100ms (and make sure we'll load the correct image)
						else
						{
							if (!slideshow.options.random) slideshow.currentImage--;
							setTimeout(function() { slideshow.fade(); }, 100);
						}
					}

					// preload next image
					slideshow.preload();
				},

				/**
				 * initialise slideshow
				 */
				init : function(options)
				{
					slideshow.options = $.extend({}, slideshow.defaults, options);
					slideshow.element = this;

					// images not passed along as parameter?
					if (slideshow.options.images.length == 0)
					{
						// get images (paths are comma-seperated in the rel-attribute)
						slideshow.options.images = slideshow.element.attr('rel').replace(/\s+/, '').split(',');

						// get links (if present), these are appended after each image path, preceded by a semi-colon
						for (var i = 0; i < slideshow.options.images.length; i++)
						{
							if (slideshow.options.images[i].indexOf(':') != -1)
							{
								var split = slideshow.options.images.split(':');
								slideshow.options.images[i] = split[0];
								slideshow.options.links[i] = split[1];
							}
						}

						// we don't need this anymore
						slideshow.element.attr('rel', '');
					}

					if (slideshow.element.attr('src'))
					{
						// check if src was in rel/images array (cause we will want that one too!)
						if ($.inArray(slideshow.element.attr('src'), slideshow.options.images) < 0) {}
						else
						{
							// however, if the img is in there already, make sure that's where we start
							slideshow.currentImage = $.inArray(slideshow.element.attr('src'), slideshow.options.images);

							if (!slideshow.options.random)
							{
								slideshow.currentImage--;
	
								// boundaries doublecheck
								if (slideshow.currentImage > slideshow.options.images.length - 1)	slideshow.currentImage = 0;
								else if (slideshow.currentImage < 0)								slideshow.currentImage = slideshow.options.images.length - 1;
							}
						}

						// get index for current image
						slideshow.currentImage == $.inArray(slideshow.element.attr('src'), slideshow.options.images) - 1;
					}

					// preload images
					slideshow.preload();

					// create 2 more images so make smooth transitions :)
					slideshow.elementNext = slideshow.element.clone().insertAfter(slideshow.element);
					slideshow.elementCurr = slideshow.element.clone().insertAfter(slideshow.element).css('z-index', '1');

					// set the positions of the 2 newly created images
					slideshow.setPosition();

					// now make the original img invisible (not display none, we still need that space)
					slideshow.element.css('visibility', 'hidden');

					// when resizing, calculate position again!
					$(window).resize(slideshow.setPosition);

					// and when the document has fully loaded, calculate again!
					$('body').ready(slideshow.setPosition);

					// let the show begin
					slideshow.fade();

					// hook previous & next
					if (slideshow.options.hookPrevious)	slideshow.options.hookPrevious.click(function() { slideshow.manual(false); return false; });
					if (slideshow.options.hookNext)		slideshow.options.hookNext.click(function() { slideshow.manual(true); return false; });

					// hook controls for a specific image
					if (slideshow.options.hookSpecific)
					{
						slideshow.options.hookSpecific.each(function(i)
						{
							// work with either a given value (in rel), or set the value ourself (based on order in which this element was found)
							if ($(this).attr('rel') == '') $(this).attr('rel', i);

							// hook it
							$(this).click(function() { slideshow.manual(parseInt($(this).attr('rel'))); return false; });
						});
					}
				},

				/**
				 * previous & next image (previous = false, next = true, image number = integer)
				 */
				manual : function(next)
				{
					// stop current timer
					clearTimeout(slideshow.timer);

					// move on to next img
					slideshow.fade(next);
				},

				/**
				 * preload images
				 */
				preload : function()
				{
					// check if this is possible in the current browser
					if (document.images)
					{
						var preload = slideshow.currentImage;

						// on init
						if (slideshow.currentImage < 0) preload = 0;

						for (var i = preload; i < slideshow.options.images.length * 2; i++) // the + length makes it easy to go from end of array to 0
						{
							// only preload the amount of images that we defined
							if (slideshow.options.preload != 0 && i - preload > slideshow.options.preload - Number(slideshow.options.random)) break;

							// already loaded?
							if (slideshow.imagesArray[i % slideshow.options.images.length]) continue;

							// load image
							slideshow.imagesArray[i % slideshow.options.images.length] = new Image();
							slideshow.imagesArray[i % slideshow.options.images.length].src = slideshow.options.images[i % slideshow.options.images.length];
						}

						// if we've hooked 'previous', then also preload some previous images
						if (slideshow.options.hookPrevious)
						{
							for (var i = slideshow.options.images.length + preload - 1; i > preload; i--) // the + length makes it easy to go from 0 to end of array
							{
								// only preload the amount of images that we defined
								if (slideshow.options.preload != 0 && - i + preload + slideshow.options.images.length > slideshow.options.preload - Number(slideshow.options.random)) break;

								// already loaded?
								if (slideshow.imagesArray[i % slideshow.options.images.length]) continue;

								// load image
								slideshow.imagesArray[i % slideshow.options.images.length] = new Image();
								slideshow.imagesArray[i % slideshow.options.images.length].src = slideshow.options.images[i % slideshow.options.images.length];
							}
						}
					}
				},

				/**
				 * set position of slideshow
				 */
				setPosition : function()
				{
					// place 'em on the correct position (right on top of the original image)
					var position = slideshow.element.position();
					slideshow.elementNext.css('position', 'absolute').css('left', position.left).css('top', position.top);
					slideshow.elementCurr.css('position', 'absolute').css('left', position.left).css('top', position.top);
				}
			};

			// init slideshow
			slideshow.init.call($(this), options);
		});
	}
});