The task was to make app that shows Belarusbank ATMs, infoboxes and filials on the map (using MapKit, Belarusbank APIs). UIActivityIndicatorView is active while app receiving data about objects via internet connection. The map has custom CalloutView with UIScrollView inside. CalloutView shows some information about object. CalloutView also has button "Details" ("Подробнее"). Button click shows new screen with detail info about the object and one more button "Make rout" ("Построить маршрут") that makes rout from your current location (CoreLocation). First ViewController has UISegmentedControl to switch between Map and list of objects sorted by cities,categories and distance from current location (UICollectionView, UICollectionViewCompositionalLayout, UICollectionViewDiffableDataSource). Choosing item in the list switches to the map and opens CalloutView of choosen item. The map also has NavigationBar with 2 BarButtonItems. Left BarButtonItem allows to filter what types of objects display on the map. Right BarButtonItem allows to refresh information about Belarusbank objects. App saves data to CoreData so it can work without internet connection.

https://user-images.githubusercontent.com/109769898/224336604-ec37cd3e-9dc3-4f5a-8714-87f1794e6fa0.mp4


Part 2

https://user-images.githubusercontent.com/109769898/224336702-97ca7d0d-95b3-49ee-9135-8003778bab34.mp4
