import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/auth_utils.dart';

class AdminBoardingHouses extends StatefulWidget {
  const AdminBoardingHouses({Key? key}) : super(key: key);

  @override
  _AdminBoardingHousesState createState() => _AdminBoardingHousesState();
}

class _AdminBoardingHousesState extends State<AdminBoardingHouses> {
  bool _isLoading = true;
  List<dynamic> _boardingHouses = [];
  String _searchQuery = '';
  String _filterStatus = 'all';
  String _sortBy = 'newest';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceRangeController = TextEditingController();
  int _selectedOwnerId = 0;
  List<dynamic> _owners = [];

  @override
  void initState() {
    super.initState();
    _loadBoardingHouses();
    _loadOwners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _priceRangeController.dispose();
    super.dispose();
  }

  Future<void> _loadOwners() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      final response = await http.get(
        Uri.parse('http://localhost:3001/api/admin/users?role=owner'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return http.Response('{"success":false,"message":"Timeout"}', 408);
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['users'] != null) {
          setState(() {
            _owners = data['users'];
          });
        }
      }
    } catch (e) {
      print('Lỗi khi tải danh sách chủ trọ: $e');
    }
  }

  Future<void> _loadBoardingHouses() async {
    try {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập lại')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:3001/api/admin/boarding-houses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return http.Response('{"success":false,"message":"Timeout"}', 408);
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['boarding_houses'] != null) {
          setState(() {
            _boardingHouses = data['boarding_houses'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _boardingHouses = [];
            _isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${response.statusCode}')),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBoardingHouse(int houseId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      final response = await http.delete(
        Uri.parse('http://localhost:3001/api/admin/boarding-houses/$houseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa nhà trọ thành công')),
        );
        _loadBoardingHouses(); // Tải lại danh sách
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _createBoardingHouse() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      final response = await http.post(
        Uri.parse('http://localhost:3001/api/admin/boarding-houses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'address': _addressController.text,
          'description': _descriptionController.text,
          'price_range': _priceRangeController.text,
          'owner_id': _selectedOwnerId,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context); // Đóng dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo nhà trọ thành công')),
        );
        _loadBoardingHouses(); // Tải lại danh sách
        _clearForm();
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi: ${data['message'] ?? "Lỗi không xác định"}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _addressController.clear();
    _descriptionController.clear();
    _priceRangeController.clear();
    _selectedOwnerId = 0;
  }

  void _showAddBoardingHouseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm nhà trọ mới'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Chủ trọ *'),
                  value: _selectedOwnerId != 0 ? _selectedOwnerId : null,
                  hint: const Text('Chọn chủ trọ'),
                  items: _owners.map((owner) {
                    return DropdownMenuItem<int>(
                      value: owner['id'],
                      child: Text('${owner['fullname']} (${owner['email']})'),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) return 'Vui lòng chọn chủ trọ';
                    return null;
                  },
                  onChanged: (newValue) {
                    setState(() {
                      _selectedOwnerId = newValue!;
                    });
                  },
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên nhà trọ *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên nhà trọ';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Địa chỉ *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập địa chỉ';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 3,
                ),
                TextFormField(
                  controller: _priceRangeController,
                  decoration: const InputDecoration(
                    labelText: 'Khoảng giá *',
                    hintText: 'VD: 1.5-3 triệu',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập khoảng giá';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: _createBoardingHouse,
            child: const Text('Thêm mới'),
          ),
        ],
      ),
    );
  }

  // Hiển thị danh sách nhà trọ
  Widget _buildBoardingHousesList() {
    // Filter và sort
    List<dynamic> filteredBoardingHouses = _boardingHouses.where((house) {
      final name = house['name']?.toString().toLowerCase() ?? '';
      final address = house['address']?.toString().toLowerCase() ?? '';
      final searchLower = _searchQuery.toLowerCase();

      // Tìm kiếm theo tên hoặc địa chỉ
      final matchesSearch =
          name.contains(searchLower) || address.contains(searchLower);

      return matchesSearch;
    }).toList();

    // Sắp xếp
    if (_sortBy == 'name_asc') {
      filteredBoardingHouses.sort((a, b) =>
          (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
    } else if (_sortBy == 'name_desc') {
      filteredBoardingHouses.sort((a, b) =>
          (b['name'] ?? '').toString().compareTo((a['name'] ?? '').toString()));
    } else if (_sortBy == 'rating') {
      filteredBoardingHouses
          .sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
    } else if (_sortBy == 'newest') {
      filteredBoardingHouses.sort((a, b) {
        final aDate =
            DateTime.parse(a['created_at'] ?? DateTime.now().toString());
        final bDate =
            DateTime.parse(b['created_at'] ?? DateTime.now().toString());
        return bDate.compareTo(aDate);
      });
    }

    if (filteredBoardingHouses.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy nhà trọ nào',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredBoardingHouses.length,
      itemBuilder: (context, index) {
        final house = filteredBoardingHouses[index];
        final houseId = house['id'];
        final houseName = house['name'] ?? 'Không có tên';
        final houseAddress = house['address'] ?? 'Không có địa chỉ';
        final houseRating = house['rating'] ?? 0.0;
        final totalRooms = house['total_rooms'] ?? 0;
        final priceRange = house['price_range'] ?? '';
        final houseImage = house['image'] ??
            'https://i.imgur.com/JQRGsMs.jpg'; // Hình ảnh mặc định
        final description = house['description'] ?? '';
        final ownerName = house['owner_name'] ?? 'Không có thông tin';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Phần hình ảnh bên trái
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Image.network(
                    houseImage,
                    width: 150,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 150,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 150,
                        color: Colors.grey.shade100,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Phần thông tin bên phải
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phần tiêu đề và đánh giá
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    houseName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    houseAddress,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    houseRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Phần mô tả ngắn
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Thông tin bổ sung
                        Row(
                          children: [
                            _buildInfoChip(
                              Icons.person,
                              ownerName,
                              Colors.blue.shade100,
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              Icons.house,
                              '$totalRooms phòng',
                              Colors.green.shade100,
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              Icons.attach_money,
                              priceRange,
                              Colors.purple.shade100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Phần nút thao tác
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 20),
                              color: Colors.blue,
                              tooltip: 'Xem phòng',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Xem phòng của nhà trọ $houseName',
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              color: Colors.orange,
                              tooltip: 'Chỉnh sửa',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Chỉnh sửa nhà trọ $houseName',
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              color: Colors.red,
                              tooltip: 'Xóa',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Xác nhận xóa'),
                                    content: Text(
                                      'Bạn có chắc muốn xóa nhà trọ "$houseName"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteBoardingHouse(houseId);
                                        },
                                        child: const Text(
                                          'Xóa',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.black87,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Dữ liệu mẫu/demo
  List<Map<String, dynamic>> _getDemoData() {
    return [
      {
        'id': 1,
        'name': 'Nhà trọ Hoàng Long',
        'address': '123 Nguyễn Huệ, Phường 1, Quận 1, TP.HCM',
        'description': 'Nhà trọ cao cấp, đầy đủ tiện nghi, gần trung tâm',
        'total_rooms': 15,
        'price_range': '2-3.5 triệu',
        'rating': 4.5,
        'created_at': '2023-12-10T05:32:19.000Z',
        'owner_id': 5,
        'owner_name': 'Nguyễn Văn A',
        'image': 'https://i.imgur.com/JA32Y7k.jpg',
      },
      {
        'id': 2,
        'name': 'Khu trọ sinh viên Thành Công',
        'address': '45 Lê Lợi, Phường 4, Quận 5, TP.HCM',
        'description': 'Khu trọ dành cho sinh viên, giá rẻ, gần trường đại học',
        'total_rooms': 30,
        'price_range': '1.2-2 triệu',
        'rating': 3.8,
        'created_at': '2023-10-05T09:15:42.000Z',
        'owner_id': 8,
        'owner_name': 'Trần Thị B',
        'image': 'https://i.imgur.com/pUECN7C.jpg',
      },
      {
        'id': 3,
        'name': 'Nhà trọ Thanh Bình',
        'address': '78 Võ Văn Tần, Phường 6, Quận 3, TP.HCM',
        'description': 'Khu trọ an ninh, yên tĩnh, thích hợp cho gia đình nhỏ',
        'total_rooms': 10,
        'price_range': '2.5-4 triệu',
        'rating': 4.2,
        'created_at': '2024-01-15T14:30:00.000Z',
        'owner_id': 12,
        'owner_name': 'Phạm Văn C',
        'image': 'https://i.imgur.com/rtsG5BA.jpg',
      },
      {
        'id': 4,
        'name': 'Khu trọ Tân Tiến',
        'address': '231 Nguyễn Trãi, Phường 2, Quận 5, TP.HCM',
        'description': 'Khu trọ mới xây, có gác lửng, đầy đủ nội thất',
        'total_rooms': 25,
        'price_range': '1.8-3 triệu',
        'rating': 4.0,
        'created_at': '2023-11-20T10:45:13.000Z',
        'owner_id': 15,
        'owner_name': 'Lê Thị D',
        'image': 'https://i.imgur.com/HxlUCh7.jpg',
      },
      {
        'id': 5,
        'name': 'Nhà trọ Phúc Lộc',
        'address': '56 Phạm Ngọc Thạch, Phường 6, Quận 3, TP.HCM',
        'description':
            'Khu trọ cao cấp, có bảo vệ 24/7, thang máy, máy giặt chung',
        'total_rooms': 40,
        'price_range': '3-5 triệu',
        'rating': 4.7,
        'created_at': '2024-02-01T08:20:55.000Z',
        'owner_id': 18,
        'owner_name': 'Hoàng Văn E',
        'image': 'https://i.imgur.com/9EYuBGP.jpg',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng dữ liệu mẫu khi API chưa sẵn sàng hoặc đang trong quá trình test
    if (_boardingHouses.isEmpty && !_isLoading) {
      _boardingHouses = _getDemoData();
    }

    return Scaffold(
      appBar: null,
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề trang
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  Container(
                    height: 24,
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Quản lý phòng trọ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _showAddBoardingHouseDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm nhà trọ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Thanh tìm kiếm và bộ lọc
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm nhà trọ...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration: InputDecoration(
                        labelText: 'Sắp xếp',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('Mới nhất'),
                        ),
                        DropdownMenuItem(
                          value: 'name_asc',
                          child: Text('Tên A-Z'),
                        ),
                        DropdownMenuItem(
                          value: 'name_desc',
                          child: Text('Tên Z-A'),
                        ),
                        DropdownMenuItem(
                          value: 'rating',
                          child: Text('Đánh giá'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Thống kê nhanh
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  _buildStatCard(
                    'Tổng nhà trọ',
                    _boardingHouses.length.toString(),
                    Icons.house,
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    'Tổng phòng',
                    _boardingHouses
                        .fold<int>(
                          0,
                          (prev, house) =>
                              prev + (house['total_rooms'] as int? ?? 0),
                        )
                        .toString(),
                    Icons.meeting_room,
                    Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    'Đánh giá TB',
                    _boardingHouses.isEmpty
                        ? '0.0'
                        : (_boardingHouses.fold<double>(
                                  0.0,
                                  (prev, house) =>
                                      prev +
                                      (house['rating'] as double? ?? 0.0),
                                ) /
                                _boardingHouses.length)
                            .toStringAsFixed(1),
                    Icons.star,
                    Colors.amber,
                  ),
                ],
              ),
            ),

            // Danh sách nhà trọ
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildBoardingHousesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
