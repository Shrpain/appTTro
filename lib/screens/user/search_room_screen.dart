import 'package:flutter/material.dart';

class SearchRoomScreen extends StatefulWidget {
  const SearchRoomScreen({Key? key}) : super(key: key);

  @override
  _SearchRoomScreenState createState() => _SearchRoomScreenState();
}

class _SearchRoomScreenState extends State<SearchRoomScreen> {
  RangeValues _priceRange = const RangeValues(500000, 5000000);
  RangeValues _areaRange = const RangeValues(10, 50);
  String _selectedLocation = 'Tất cả';
  bool _isAvailableOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm phòng trọ'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Column(
        children: [
          _buildSearchFilters(),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh tìm kiếm
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Nhập địa chỉ hoặc tên nhà trọ...',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Khoảng giá
          const Text(
            'Khoảng giá (nghìn đồng)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: _priceRange,
            min: 500000,
            max: 5000000,
            divisions: 45,
            labels: RangeLabels(
              '${(_priceRange.start / 1000).round()}k',
              '${(_priceRange.end / 1000).round()}k',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),

          // Diện tích
          const Text(
            'Diện tích (m²)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: _areaRange,
            min: 10,
            max: 50,
            divisions: 40,
            labels: RangeLabels(
              '${_areaRange.start.round()}m²',
              '${_areaRange.end.round()}m²',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _areaRange = values;
              });
            },
          ),

          // Các bộ lọc khác
          Row(
            children: [
              // Dropdown khu vực
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Khu vực',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedLocation,
                  items: ['Tất cả', 'Quận 1', 'Quận 2', 'Quận 3']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLocation = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Checkbox còn phòng
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Còn phòng'),
                  value: _isAvailableOnly,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAvailableOnly = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10, // Số lượng kết quả mẫu
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh phòng trọ
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên và đánh giá
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nhà trọ ${index + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '4.${5 - (index % 5)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Địa chỉ
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Địa chỉ mẫu ${index + 1}, Quận ${1 + (index % 12)}, TP.HCM',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Thông tin chi tiết
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.straighten,
                          '${20 + (index % 30)}m²',
                        ),
                        const SizedBox(width: 16),
                        _buildInfoChip(
                          Icons.attach_money,
                          '${1 + (index % 5)}.${(index % 9)}tr',
                        ),
                        const SizedBox(width: 16),
                        _buildInfoChip(
                          Icons.meeting_room,
                          'Còn ${1 + (index % 5)} phòng',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nút đặt phòng
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Xử lý đặt phòng
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Đặt phòng',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
