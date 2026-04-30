import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String? stock;
  final String? price;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final bool showAddButton;

  const ProductCard({
    super.key,
    required this.name,
    this.imageUrl,
    this.stock,
    this.price,
    this.onTap,
    this.onAdd,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.water_drop,
                          color: AppColors.primary.withOpacity(0.5),
                          size: 32,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.water_drop,
                    color: AppColors.primary.withOpacity(0.5),
                    size: 32,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (stock != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '现货: $stock',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (price != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    price!,
                    style: AppTextStyles.priceSmall,
                  ),
                ],
              ],
            ),
          ),
          if (showAddButton)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProductListItem extends StatelessWidget {
  final String name;
  final String quantity;
  final String? price;
  final String? imageUrl;
  final VoidCallback? onTap;

  const ProductListItem({
    super.key,
    required this.name,
    required this.quantity,
    this.price,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgInput,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.water_drop,
                            color: AppColors.primary.withOpacity(0.5),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.water_drop,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.subtitle2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (price != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      price!,
                      style: AppTextStyles.priceSmall,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '× $quantity',
              style: AppTextStyles.subtitle2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
