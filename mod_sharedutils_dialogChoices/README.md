# Dialog choices
A quick and easy way to display dialog choices to the player and to listen for the response, done with code and without any bundling.

## Using it

The [example file](./example/main.ws) should show everything you need to know to create a basic dialog choice and listen for the response. Here is what the example code creates: [Youtube link](https://www.youtube.com/watch?v=n1LvHQClKdY).

Basically, you fill an array with the difference choices you want to show to the player. Then you either create an event listener class or you use the latent function that will wait for the player and will return the choice.
The example code shows how to use the event listener class as it is the most complex of the two.