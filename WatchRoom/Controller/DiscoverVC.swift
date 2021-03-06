//
//  DiscoverVC.swift
//  WatchRoom
//
//  Created by Bogdan on 19/8/20.
//

import UIKit
import FirebaseCrashlytics
import SafariServices

class DiscoverVC: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: Variables
    var trendingMovies = [MovieDetail]()
    var trendingMoviesPage = 1
    var nowPlayingMovies = [MovieDetail]()
    var nowPlayingMoviesPage = 1
    var upcomingMovies = [MovieDetail]()
    var upcomingMoviesPage = 1
    
    var selectedMovie: MovieDetail!
        
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        configureCollectionView()
        loadMovies()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.activityIndicator.stopAnimating()
            self.collectionView.fadeIn(0.5)
        }
    }
    
    //MARK: CollectionView configuration
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.allowsMultipleSelection = true
        collectionView.contentInset.bottom = 16
        
        collectionView.register(MovieCell.nib, forCellWithReuseIdentifier: MovieCell.id)
        collectionView.register(SectionHeader.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.id)
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionNumber, _) -> NSCollectionLayoutSection? in
            switch sectionNumber {
            case 0:
                return self.trendingMoviesSection()
            case 1:
                return self.nowPlayingMoviesSection()
            case 2:
                return self.upcomingMoviesSection()
            default:
                return self.trendingMoviesSection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        layout.configuration = config
        return layout
    }
    
    //MARK: CollectionViewLayout sections
    
    /// - Tag: popularMovies section
    func trendingMoviesSection() -> NSCollectionLayoutSection {
        let inset = CGFloat(16)
        let posterHeight = CGFloat(380)
        let posterWidth = CGFloat(posterHeight / 1.5) + inset
        
        //define item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //configurate item
        item.contentInsets.trailing = inset
        
        //define group
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(posterWidth), heightDimension: .absolute(posterHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        
        //define section
        let section = NSCollectionLayoutSection(group: group)
        
        //configure section
        section.contentInsets.leading = 16
        section.orthogonalScrollingBehavior = .groupPaging
        
        //configure header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45))
        section.boundarySupplementaryItems = [
            .init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        return section
    }
    
    /// - Tag: nowPlayingMovies section
    func nowPlayingMoviesSection() -> NSCollectionLayoutSection {
        let inset = CGFloat(12)
        let posterHeight = CGFloat(220)
        let posterWidth = CGFloat(posterHeight / 1.5) + inset
        
        //define item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //configurate item
        item.contentInsets.trailing = inset
        
        //define group
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(posterWidth), heightDimension: .absolute(posterHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        
        //define section
        let section = NSCollectionLayoutSection(group: group)
        
        //configure section
        section.contentInsets.leading = 16
        section.orthogonalScrollingBehavior = .continuous
        
        //configure header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45))
        section.boundarySupplementaryItems = [
            .init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        return section
    }
    
    /// - Tag: upcomingMovies section
    func upcomingMoviesSection() -> NSCollectionLayoutSection {
        let inset = CGFloat(12)
        let posterHeight = CGFloat(220)
        let posterWidth = CGFloat(posterHeight / 1.5) + inset
        
        //define item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //configurate item
        item.contentInsets.trailing = inset
        
        //define group
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(posterWidth), heightDimension: .absolute(posterHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        
        //define section
        let section = NSCollectionLayoutSection(group: group)
        
        //configure section
        section.contentInsets.leading = 16
        section.orthogonalScrollingBehavior = .continuous
        
        //configure header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45))
        section.boundarySupplementaryItems = [
            .init(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        return section
    }
    
    //MARK: Load movies
    func loadMovies() {
        loadTrendingMovies(page: 1, section: 0)
        loadNowPlayingMovies(page: 1, section: 1)
        loadUpcomingMovies(page: 1, section: 2)
    }
    
    /// - Tag: Load popular movies
    func loadTrendingMovies(page: Int, section: Int) {
        let path = TMDB_API.v3.Movie.TrendingTodayURL
        let parameters = [
            "api_key": Secrets.MOVIEDB_API_KEY,
            "page": String(page)
        ]
        
        MovieService.shared.getMovies(path: path, parameters: parameters) { [weak self](result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                    self.presentSimpleAlert(withTitle: "Something went wrong", message: error.rawValue)
                case .success(let feed):
                    if let movies = feed.movies, movies.count > 0 {
                        if page > 1 {
                            var indexPaths = [IndexPath]()
                            for item in 0..<movies.count {
                                let indexPath = IndexPath(row: item + self.trendingMovies.count, section: section)
                                indexPaths.append(indexPath)
                            }
                            self.collectionView.performBatchUpdates({
                                self.trendingMovies.append(contentsOf: movies)
                                self.collectionView.insertItems(at: indexPaths)
                                
                            }, completion: nil)
                            
                        } else {
                            self.trendingMovies.append(contentsOf: movies)
                            self.collectionView.reloadSections(IndexSet(integer: section))
                        }
                    }
                }
            }
        }
    }
    
    /// - Tag: Now playing movies
    func loadNowPlayingMovies(page: Int, section: Int) {
        let path = TMDB_API.v3.Movie.NowPlayingURL
        let parameters = [
            "api_key": Secrets.MOVIEDB_API_KEY,
            "page": String(page),
            "language": UserLocale.language,
            "region": UserLocale.region,
            "include_adult": "false",
        ]
        
        MovieService.shared.getMovies(path: path, parameters: parameters) { [weak self](result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                    self.presentSimpleAlert(withTitle: "Something went wrong", message: error.rawValue)
                case .success(let feed):
                    if let movies = feed.movies, movies.count > 0 {
                        if page > 1 {
                            var indexPaths = [IndexPath]()
                            for item in 0..<movies.count {
                                let indexPath = IndexPath(row: item + self.nowPlayingMovies.count, section: section)
                                indexPaths.append(indexPath)
                            }
                            self.collectionView.performBatchUpdates({
                                self.nowPlayingMovies.append(contentsOf: movies)
                                self.collectionView.insertItems(at: indexPaths)
                                
                            }, completion: nil)
                            
                        } else {
                            self.nowPlayingMovies.append(contentsOf: movies)
                            self.collectionView.reloadSections(IndexSet(integer: section))
                        }
                    }
                }
            }
        }
    }
    
    /// - Tag: Upcoming movies
    func loadUpcomingMovies(page: Int, section: Int) {
        let path = TMDB_API.v3.Movie.UpcomingURL
        let parameters = [
            "api_key": Secrets.MOVIEDB_API_KEY,
            "page": String(page),
            "language": UserLocale.language,
            "region": UserLocale.region,
            "include_adult": "false",
        ]
        
        MovieService.shared.getMovies(path: path, parameters: parameters) { [weak self](result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                    self.presentSimpleAlert(withTitle: "Something went wrong", message: error.rawValue)
                case .success(let feed):
                    if let movies = feed.movies, movies.count > 0 {
                        if page > 1 {
                            var indexPaths = [IndexPath]()
                            for item in 0..<movies.count {
                                let indexPath = IndexPath(row: item + self.upcomingMovies.count, section: section)
                                indexPaths.append(indexPath)
                            }
                            self.collectionView.performBatchUpdates({
                                self.upcomingMovies.append(contentsOf: movies)
                                self.collectionView.insertItems(at: indexPaths)
                                
                            }, completion: nil)
                            
                        } else {
                            self.upcomingMovies.append(contentsOf: movies)
                            self.collectionView.reloadSections(IndexSet(integer: section))
                        }
                    }
                }
            }
        }
    }
    
}

//MARK: UICollectionViewDelegate implementation
extension DiscoverVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            selectedMovie = trendingMovies[indexPath.item]
        case 1:
            selectedMovie = nowPlayingMovies[indexPath.item]
        case 2:
            selectedMovie = upcomingMovies[indexPath.item]
        default:break
        }
        
        let storyboard = UIStoryboard(name: StoryboardIDs.MainStoryboard, bundle: nil)
        let movieDetailVC = storyboard.instantiateViewController(withIdentifier: VCIDs.MovieDetailVC) as! MovieDetailVC
        movieDetailVC.id = selectedMovie.id
        present(movieDetailVC, animated: true, completion: nil)
    }
}

//MARK: UICollectionViewDataSource implementation
extension DiscoverVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return trendingMovies.count
        case 1: return nowPlayingMovies.count
        case 2: return upcomingMovies.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.id, for: indexPath) as! MovieCell
            cell.configure(movie: trendingMovies[indexPath.item])
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.id, for: indexPath) as! MovieCell
            cell.configure(movie: nowPlayingMovies[indexPath.item])
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.id, for: indexPath) as! MovieCell
            cell.configure(movie: upcomingMovies[indexPath.item])
            return cell
        default: return UICollectionViewCell()
        }
    }
}

//MARK: UICollectionViewDelegateFlowLayout implementation
extension DiscoverVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.id, for: indexPath) as! SectionHeader
            
            switch indexPath.section {
            case 0:
                header.configure(section: Section(title: "Trending today", fontSize: nil, type: .trending), delegate: self)
            case 1:
                header.configure(section: Section(title: "Now streaming", fontSize: nil, type: .playing), delegate: self)
            case 2:
                header.configure(section: Section(title: "Coming soon", fontSize: nil, type: .upcoming), delegate: self)
            default: break
            }
            return header
        default: return UICollectionReusableView()
        }
    }
}

extension DiscoverVC: SectionHeaderDelegate {
    func seeAll(section: Section) {
        let storyboard = UIStoryboard(name: StoryboardIDs.MainStoryboard, bundle: nil)
        let allMoviesVC = storyboard.instantiateViewController(withIdentifier: VCIDs.AllMoviesVC) as! AllMoviesVC
        allMoviesVC.section = section
        
        present(allMoviesVC, animated: true, completion: nil)
    }
}
