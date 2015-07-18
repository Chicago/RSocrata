Hi @tomschenkjr, 
Can I just ask something ? We have a function called posixify which "Converts Socrata calendar_date string to POSIX". Can you give me an example of a such string that is then converted to POSIX ?

Because by looking at http://dev.socrata.com/docs/datatypes/ there is only http://dev.socrata.com/docs/datatypes/floating_timestamp.html which has format `2014-10-13T00:00:00.000`. I suppose that is it, right ?

I was also looking here https://www.apichangelog.com/api/socrata and couldn’t find any information about "calendar data", except for https://data.cityofchicago.org/developers/docs/alternative-fuel-locations which returns "expected_date" in a "calendar_date" format (which is again the format above"