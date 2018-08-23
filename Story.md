<!-- 

Fork and tell your story here, then PR. 
EXAMPLE:

## Title: 从删库到跑路

Author: example mail@example.com

…

-->
## I erased a big bank's account data

Author: hotvulcan hotvulcan@gmail.com

Many years ago, I got a project from a big unit( something like a company but belongs to the state of China ) in China. That includes an interface in a big bank's front machine. It was early years, IT security was not as serious as today. So they put me in a small chamber and gave me access to that front. The project was not officially online but had some transactions already. some hundreds of thousands CNY a day.

It was the end of a month, I had to remove the test data so they can do the settle. the SQL was something like "delete from journals where done_by = 'example';".  I worked 36+ hours and got very tired, typoed it to "delete from journals ; where done_by 'example'". and the journals were gone. 

I was freezed about ten years, as I feel, and start to think. The information was available from other tables, but that day's journal data were lost. But the project is still in debug mode. so I have enough logs to re-calculate that data. I wrote a Perl script. the data got back. I didn't have to go to jail or run away...

"Some hundreds of thousands CNY" could buy a big apartment in Beijing or 200~300 ounces gold in that year. 



## PR your story here 
Fork and tell your story here, then PR. 
EXAMPLE:

 ## Title: 从删库到跑路

Author: example mail@example.com

…
