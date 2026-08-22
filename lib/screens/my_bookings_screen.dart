import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/data_provider.dart';
import '../widgets/ui.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<DataProvider>().fetchBookings();
    });
  }

  Future<void> _cancelBooking(BuildContext context, int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<DataProvider>().cancelBooking(bookingId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Booking cancelled.' : 'Failed to cancel booking.')),
        );
      }
    }
  }

  void _showReviewSheet(BuildContext context, int bookingId) {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Write a Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (i) {
                        final star = i + 1;
                        return IconButton(
                          icon: Icon(
                            star <= selectedRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 36,
                          ),
                          onPressed: () => setSheetState(() => selectedRating = star),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share your experience (optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(sheetCtx).pop();
                        final comment = commentController.text.trim();
                        final success = await context.read<DataProvider>().submitReview(
                          bookingId: bookingId,
                          rating: selectedRating,
                          comment: comment.isEmpty ? null : comment,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? 'Review submitted! Thank you.' : 'Failed to submit review.'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      child: const Text('Submit Review'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          if (data.isLoading && data.bookings.isEmpty) {
            return const AppSkeletonList(itemHeight: 130);
          }

          if (data.error != null && data.bookings.isEmpty) {
            return EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Something went wrong',
              subtitle: data.error,
              actionLabel: 'Retry',
              onAction: () => data.fetchBookings(),
            );
          }

          if (data.bookings.isEmpty) {
            return EmptyState(
              icon: Icons.calendar_month_rounded,
              title: 'No bookings yet',
              subtitle: 'When you book a professional, your appointments will appear here.',
              actionLabel: 'Refresh',
              onAction: () => data.fetchBookings(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => data.fetchBookings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: data.bookings.length,
              itemBuilder: (context, index) {
                final booking = data.bookings[index];
                final status = booking.status.toLowerCase();
                final isPending = status == 'pending';
                final isCompleted = status == 'completed';
                final hasReview = booking.review != null;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.professional?.name ?? 'Professional',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            _buildStatusChip(booking.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.service?.name ?? booking.professionalService?.name ?? 'Service',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${booking.bookingDate}  ${booking.bookingTime}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Spacer(),
                            _typeChip(booking.isRequest),
                          ],
                        ),
                        if (booking.isRequest && booking.customerAddress != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.home_outlined, size: 14, color: kSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  booking.customerAddress!,
                                  style: const TextStyle(fontSize: 12, color: kSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (isCompleted && hasReview) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ...List.generate(
                                booking.review!.rating,
                                (_) => const Icon(Icons.star, color: Colors.amber, size: 14),
                              ),
                              const SizedBox(width: 4),
                              const Text('Reviewed', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                        if (isPending) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _cancelBooking(context, booking.id),
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text('Cancel'),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                            ),
                          ),
                        ] else if (isCompleted && !hasReview) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _showReviewSheet(context, booking.id),
                              icon: const Icon(Icons.star_outline, size: 18),
                              label: const Text('Write Review'),
                              style: TextButton.styleFrom(foregroundColor: Colors.amber[800]),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _typeChip(bool isRequest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isRequest ? kSecondarySoft : kPrimarySoft,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isRequest ? kSecondary : kPrimary,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRequest ? Icons.home_outlined : Icons.store_outlined,
            size: 11,
            color: isRequest ? kSecondary : kPrimary,
          ),
          const SizedBox(width: 3),
          Text(
            isRequest ? 'Home' : 'In-Studio',
            style: TextStyle(
              fontSize: 10,
              color: isRequest ? kSecondary : kPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
}
