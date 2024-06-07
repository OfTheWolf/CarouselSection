# CarouselSection
Carousel implementation with UICollectionViewCompositionalLayout

# Usage

    private lazy var carouselSection: CarouselSection = {
        CarouselSection(collectionView: collectionView)
    }()

    private lazy var layout: UICollectionViewLayout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
        guard let self else { return nil }
        return self.carouselSection.layoutSection()
    }


# Demo
![Demo](https://miro.medium.com/v2/resize:fit:1200/format:webp/1*vxXHzHoML1-pmFz0nP2Sng.gif)
