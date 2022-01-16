# Essential Feed
### iOS Lead Essentials Course - Caio Zullo and Mike Apostolakis 

## Story: Customer requests to see their image feed
### Narrative #1
```
As an online customer 
I want the app to automatically load my latest audio feed
So that I can enjoy the latest audio clips from my friends
```

### Acceptance Criteria
```
Given that the customer has an active internet connection
When the customer opens their audio feed
Then new items are loaded into their feed from the remote API and cached.
```

### Narrative #2
```
As an offline customer
I want the app to automatically load the latest saved version of my audio feed
So that I can enjoy past audio clips from my friends.
```

### Acceptance Crtiera
```
Given that the customer does not have an active internet connection
And the cache has audio clips
When the customer opens their audio feed
Then the items are loaded into their feed from the cache
```
```
Given that the customer does not have an active internet connection
And the cache has no audio clips
When the customer opens their audio feed
Then an error is delivered to the cusomer
```

## Use Cases

### Remote Feed Use Case
```
Data:
- URL

Primary course:
1. Execute "Load Feed Items" command with the URL
2. System downloads data from remote
3. System validates data
4. System creates feed items from valid data
5. Sytem saves data to cache (refer to Cache Feed Items Use Case)
6. System delivers feed items

Invalid data:
1. System delivers invalid data error

No connectivity:
1. System delivers no connectivity error
```

### Cached Feed Use Cases
```
Data:
- Timestamp

Primary Course:
1. Execute "Load Feed Items" command
2. System downloads data from cache
3. System validates data using the timestamp
4. System removes invalid data from the cache
5. System creates feed items
6. System deliver feed items.

Invalid data:
1. System delivers invalid data error

No Data:
1. System delivers no data error
```

### Cache Feed Items Use Case
```
Data:
- Feed Item

Priamry Course:
1. Execute "Cache Item" command
2. Systems encodes feed item
3. System timestamps feed item
4. System replaces the cache with new data
5. System invlidates old data.
```

### Save Feed Items To Remote Use Case
```
Data:
- Feed Item

Primary course:
1. Execute "Save Item" command
2. Systems encodes feed item
3. System POSTS feed item to remote
4. System deliver success message

No internet connectivity:
- System delivers no internet connection error
```
