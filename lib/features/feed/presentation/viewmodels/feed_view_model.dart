import 'package:flutter/material.dart';
import '../../../../data/models/post.dart';
import '../../../../data/models/whatsapp_status.dart';
import '../../../../core/services/whatsapp_status_service.dart';
import '../../../../core/services/permission_service.dart';

class FeedViewModel extends ChangeNotifier {
  int _selectedTabIndex = 0;
  List<Post> _posts = [];
  bool _isLoading = false;

  int get selectedTabIndex => _selectedTabIndex;
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  final List<String> tabs = ['Images', 'Videos'];

  FeedViewModel() {
    _loadSampleData();
  }

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
    _loadPostsForTab(index);
  }

  void toggleLike(String postId) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        isLiked: !_posts[index].isLiked,
        likes: _posts[index].isLiked
            ? _posts[index].likes - 1
            : _posts[index].likes + 1,
      );
      notifyListeners();
    }
  }

  void toggleSave(String postId) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(isSaved: !_posts[index].isSaved);
      notifyListeners();
    }
  }

  void _loadPostsForTab(int tabIndex) {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _posts = getSamplePostsForTab(tabIndex);
      _isLoading = false;
      notifyListeners();
    });
  }

  void _loadSampleData() {
    _posts = getSamplePostsForTab(0);
  }

  List<Post> getSamplePostsForTab(int tabIndex) {
    // Sample data that changes based on tab
    final basePosts = [
      Post(
        id: '1',
        title: 'Payday – Online Banking Website',
        description:
            'Modern banking interface with sleek design and intuitive user experience.',
        type: PostType.banking,
        author: 'Sarah Johnson',
        timeAgo: '2h ago',
        likes: 234,
        comments: 12,
        isLiked: false,
        isSaved: true,
        tags: ['Banking', 'Finance', 'UI/UX'],
        aspectRatio: 16 / 10,
      ),
      Post(
        id: '2',
        title: 'Maybe it had to happen',
        description:
            'Reflections on design philosophy and the evolution of digital experiences.',
        type: PostType.text,
        author: 'Alex Chen',
        timeAgo: '4h ago',
        likes: 89,
        comments: 23,
        isLiked: true,
        isSaved: false,
        tags: ['Philosophy', 'Design'],
        backgroundColor: '#8B5CF6',
        aspectRatio: 1.0,
      ),
      Post(
        id: '3',
        title: 'Modern Living Room Design',
        description:
            'Minimalist interior design with natural lighting and contemporary furniture.',
        imageUrl:
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
        type: PostType.image,
        author: 'Emma Wilson',
        timeAgo: '6h ago',
        likes: 156,
        comments: 8,
        isLiked: false,
        isSaved: false,
        tags: ['Interior', 'Design', 'Modern'],
        aspectRatio: 4 / 5,
      ),
      Post(
        id: '4',
        title: 'Living Room Makeover Tutorial',
        description:
            'Step-by-step guide to transforming your living space on a budget.',
        imageUrl:
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
        videoUrl: 'sample_video.mp4',
        type: PostType.video,
        author: 'Design Studio',
        timeAgo: '1d ago',
        likes: 423,
        comments: 34,
        isLiked: true,
        isSaved: true,
        tags: ['Tutorial', 'Budget', 'DIY'],
        aspectRatio: 16 / 9,
      ),
      Post(
        id: '5',
        title: 'The Future of Web Design',
        description:
            'Exploring upcoming trends in web development and user interface design.',
        type: PostType.text,
        author: 'Tech Insider',
        timeAgo: '1d ago',
        likes: 67,
        comments: 15,
        isLiked: false,
        isSaved: false,
        tags: ['Web Design', 'Trends'],
        backgroundColor: '#059669',
        aspectRatio: 3 / 4,
      ),
      Post(
        id: '6',
        title: 'Sustainable Architecture',
        description:
            'Eco-friendly building designs that harmonize with nature.',
        imageUrl:
            'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400',
        type: PostType.image,
        author: 'Green Builder',
        timeAgo: '2d ago',
        likes: 89,
        comments: 6,
        isLiked: false,
        isSaved: true,
        tags: ['Architecture', 'Sustainability'],
        aspectRatio: 3 / 4,
      ),
      Post(
        id: '7',
        title: 'Cooking Tutorial: Pasta',
        description:
            'Learn how to make perfect pasta from scratch with simple ingredients.',
        imageUrl:
            'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400',
        videoUrl: 'cooking_tutorial.mp4',
        type: PostType.video,
        author: 'Chef Maria',
        timeAgo: '3h ago',
        likes: 342,
        comments: 28,
        isLiked: false,
        isSaved: true,
        tags: ['Cooking', 'Tutorial', 'Food'],
        aspectRatio: 16 / 9,
      ),
      Post(
        id: '8',
        title: 'Workout Routine',
        description: '15-minute morning workout to boost your energy levels.',
        imageUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        videoUrl: 'workout_routine.mp4',
        type: PostType.video,
        author: 'Fitness Coach',
        timeAgo: '5h ago',
        likes: 198,
        comments: 15,
        isLiked: true,
        isSaved: false,
        tags: ['Fitness', 'Health', 'Morning'],
        aspectRatio: 9 / 16,
      ),
      Post(
        id: '9',
        title: 'Travel Vlog: Japan',
        description:
            'Exploring the beautiful temples and modern cities of Japan.',
        imageUrl:
            'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
        videoUrl: 'travel_japan.mp4',
        type: PostType.video,
        author: 'Travel Explorer',
        timeAgo: '8h ago',
        likes: 567,
        comments: 45,
        isLiked: false,
        isSaved: true,
        tags: ['Travel', 'Japan', 'Culture'],
        aspectRatio: 16 / 9,
      ),
      Post(
        id: '10',
        title: 'Music Production Tips',
        description: 'Learn the basics of beat making and music production.',
        imageUrl:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        videoUrl: 'music_production.mp4',
        type: PostType.video,
        author: 'Beat Maker',
        timeAgo: '12h ago',
        likes: 276,
        comments: 22,
        isLiked: true,
        isSaved: true,
        tags: ['Music', 'Production', 'Tutorial'],
        aspectRatio: 4 / 3,
      ),
    ];

    // Filter posts based on tab
    switch (tabIndex) {
      case 0: // Images tab
        return basePosts
            .where(
              (post) =>
                  post.type == PostType.image ||
                  post.type == PostType.banking ||
                  post.type == PostType.text,
            )
            .toList();
      case 1: // Videos tab
        return basePosts.where((post) => post.type == PostType.video).toList();
      default:
        return basePosts
            .where(
              (post) =>
                  post.type == PostType.image ||
                  post.type == PostType.banking ||
                  post.type == PostType.text,
            )
            .toList();
    }
  }
}
