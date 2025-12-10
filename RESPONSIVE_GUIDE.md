# Responsive Design Guide

This guide explains how to use the responsive utilities in the Renva app to ensure all UI elements work perfectly across all screen sizes.

## Table of Contents
1. [Core Concepts](#core-concepts)
2. [Quick Start](#quick-start)
3. [Responsive Utilities](#responsive-utilities)
4. [Widgets](#widgets)
5. [Examples](#examples)
6. [Migration Guide](#migration-guide)

## Core Concepts

### Screen Size Categories
- **Mobile**: < 600px width
  - Small Mobile: < 360px
  - Medium Mobile: 360-400px
  - Large Mobile: 400-600px
- **Tablet**: 600-1024px width
- **Desktop**: >= 1024px width

### Adaptive Values
The system automatically scales values based on screen size:
- Mobile: base value
- Tablet: base value × 1.1
- Desktop: base value × 1.2

## Quick Start

### 1. Import the utilities
```dart
import 'package:renva0/core/utils/responsive.dart';
import 'package:renva0/core/widgets/responsive_layout.dart';
import 'package:renva0/core/widgets/responsive_button.dart';
import 'package:renva0/core/widgets/responsive_text_field.dart';
```

### 2. Use responsive context extensions
```dart
@override
Widget build(BuildContext context) {
  final r = context.responsive;

  return Container(
    padding: EdgeInsets.all(r.space16),
    child: Text(
      'Hello',
      style: TextStyle(fontSize: r.fontSize16),
    ),
  );
}
```

## Responsive Utilities

### Accessing Responsive Values
```dart
// Method 1: Using context extension
final r = context.responsive;

// Method 2: Creating instance
final r = Responsive(context);
```

### Screen Dimensions
```dart
r.width          // Screen width
r.height         // Screen height
r.isMobile       // true if width < 600
r.isTablet       // true if 600 <= width < 1024
r.isDesktop      // true if width >= 1024
r.isSmallMobile  // true if width < 360
```

### Percentage-based Sizing
```dart
r.wp(50)  // 50% of screen width
r.hp(30)  // 30% of screen height
```

### Font Sizes (Auto-scaling)
```dart
r.fontSize10   // 10/11/12 (mobile/tablet/desktop)
r.fontSize12   // 12/13/14
r.fontSize14   // 14/15/16
r.fontSize16   // 16/17/18
r.fontSize18   // 18/19/20
r.fontSize20   // 20/22/24
r.fontSize24   // 24/26/28
r.fontSize28   // 28/30/32
```

### Spacing (Auto-scaling)
```dart
r.space4    // 4/5/6
r.space8    // 8/9/10
r.space12   // 12/13/14
r.space16   // 16/18/20
r.space20   // 20/22/24
r.space24   // 24/26/28
r.space32   // 32/36/40
r.space48   // 48/52/56
```

### Icon Sizes
```dart
r.iconSize16   // 16/18/20
r.iconSize20   // 20/22/24
r.iconSize24   // 24/26/28
r.iconSize32   // 32/36/40
r.iconSize48   // 48/52/56
```

### Border Radius
```dart
r.radius8    // 8/9/10
r.radius12   // 12/13/14
r.radius16   // 16/18/20
r.radius20   // 20/22/24
r.radius24   // 24/26/28
```

### Button Heights
```dart
r.buttonHeightSmall   // 40/44/48
r.buttonHeightMedium  // 48/52/56
r.buttonHeightLarge   // 56/60/64
```

### Adaptive Padding
```dart
r.screenPadding  // 16/20/24 on all sides
r.cardPadding    // 12/14/16 on all sides
r.buttonPadding  // 16/20/24 horizontal
```

### Custom Values
```dart
// Return different values based on screen size
r.value<int>(
  mobile: 2,
  tablet: 3,
  desktop: 4,
)

// Example: Grid columns
int columns = r.value(mobile: 2, tablet: 3, desktop: 4);
```

## Widgets

### ResponsiveContainer
Centers content on larger screens with max width constraint.

```dart
ResponsiveContainer(
  maxWidth: 800,  // Optional, defaults to responsive max
  padding: EdgeInsets.all(20),  // Optional
  child: YourContent(),
)
```

### ResponsiveGrid
Auto-adaptive grid with column count based on screen size.

```dart
ResponsiveGrid(
  spacing: 16,
  runSpacing: 16,
  childAspectRatio: 1.0,
  children: [
    ServiceCard(...),
    ServiceCard(...),
    ServiceCard(...),
  ],
)
```

### ResponsiveRowColumn
Automatically converts Row to Column on small screens.

```dart
ResponsiveRowColumn(
  spacing: 16,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  forceColumn: false,  // Set true to always use Column
  children: [
    Button1(),
    Button2(),
  ],
)
```

### ResponsivePadding
Adaptive padding that scales with screen size.

```dart
ResponsivePadding(
  all: 16,  // Scales to 16/18/20
  child: YourWidget(),
)

ResponsivePadding(
  horizontal: 20,
  vertical: 16,
  child: YourWidget(),
)
```

### ResponsiveCard
Card with adaptive padding and border radius.

```dart
ResponsiveCard(
  elevation: 2,
  margin: EdgeInsets.all(8),
  onTap: () {},
  child: YourContent(),
)
```

### ResponsiveButton
Primary button with adaptive sizing.

```dart
ResponsiveButton(
  text: 'Submit',
  onPressed: () {},
  size: ButtonSize.medium,  // small, medium, large
  icon: Icons.check,
  isLoading: false,
  width: double.infinity,  // Optional, defaults to full width
)
```

### ResponsiveOutlinedButton
Outlined button with adaptive sizing.

```dart
ResponsiveOutlinedButton(
  text: 'Cancel',
  onPressed: () {},
  size: ButtonSize.medium,
  borderColor: Colors.red,
  textColor: Colors.red,
)
```

### ResponsiveTextField
Form field with adaptive sizing and styling.

```dart
ResponsiveTextField(
  controller: nameController,
  hintText: 'Enter your name',
  labelText: 'Name',
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
  prefixIcon: Icon(Icons.person),
)
```

## Examples

### Example 1: Responsive Service Card
```dart
class ServiceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return ResponsiveCard(
      elevation: 2,
      child: Column(
        children: [
          // Icon with responsive size
          Icon(
            Icons.home,
            size: r.iconSize48,
            color: Colors.blue,
          ),
          SizedBox(height: r.space12),

          // Title with responsive font
          Text(
            'Service Name',
            style: TextStyle(
              fontSize: r.fontSize16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: r.space8),

          // Description with responsive font
          Text(
            'Service description',
            style: TextStyle(
              fontSize: r.fontSize12,
              color: Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Responsive Dialog
```dart
void showResponsiveDialog(BuildContext context) {
  final r = context.responsive;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r.radius20),
      ),
      child: Padding(
        padding: EdgeInsets.all(r.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Confirmation',
              style: TextStyle(
                fontSize: r.fontSize20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: r.space16),

            // Content
            Text(
              'Are you sure you want to continue?',
              style: TextStyle(fontSize: r.fontSize14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r.space24),

            // Buttons
            ResponsiveRowColumn(
              spacing: r.space12,
              children: [
                Expanded(
                  child: ResponsiveOutlinedButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: ResponsiveButton(
                    text: 'Confirm',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
```

### Example 3: Responsive Screen Layout
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      body: ResponsiveContainer(
        padding: r.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Screen Title',
              style: TextStyle(
                fontSize: r.fontSize24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: r.space16),

            // Subtitle
            Text(
              'Description goes here',
              style: TextStyle(
                fontSize: r.fontSize14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: r.space24),

            // Form fields
            ResponsiveTextField(
              labelText: 'Name',
              hintText: 'Enter your name',
            ),
            SizedBox(height: r.space16),

            ResponsiveTextField(
              labelText: 'Email',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: r.space24),

            // Submit button
            ResponsiveButton(
              text: 'Submit',
              onPressed: () {},
              size: ButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }
}
```

## Migration Guide

### Before (Hardcoded values)
```dart
Container(
  padding: EdgeInsets.all(16),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16),
  ),
)
```

### After (Responsive)
```dart
Container(
  padding: EdgeInsets.all(context.responsive.space16),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: context.responsive.fontSize16),
  ),
)
```

### Or using ResponsivePadding
```dart
ResponsivePadding(
  all: 16,
  child: Text(
    'Hello',
    style: TextStyle(fontSize: context.responsive.fontSize16),
  ),
)
```

## Best Practices

1. **Always use responsive values** for spacing, fonts, and sizes
2. **Test on different screen sizes** (use Flutter DevTools device selector)
3. **Use ResponsiveRowColumn** for layouts that should stack on mobile
4. **Use ResponsiveGrid** for card grids
5. **Use ResponsiveContainer** for page-level layouts
6. **Avoid hardcoded pixel values** - always use responsive utilities

## Testing Different Screen Sizes

In Flutter DevTools:
1. Click on the "Toggle Platform Mode" button
2. Select different devices from the dropdown
3. Test on:
   - iPhone SE (375px - small mobile)
   - iPhone 12 (390px - medium mobile)
   - iPad (768px - tablet)
   - Desktop (1024px+ - desktop)

## Common Patterns

### Pattern 1: Responsive Grid Cards
```dart
ResponsiveGrid(
  spacing: context.responsive.space16,
  children: services.map((service) => ServiceCard(service)).toList(),
)
```

### Pattern 2: Responsive Form
```dart
Form(
  child: Column(
    children: [
      ResponsiveTextField(labelText: 'Field 1'),
      SizedBox(height: context.responsive.space16),
      ResponsiveTextField(labelText: 'Field 2'),
      SizedBox(height: context.responsive.space24),
      ResponsiveButton(text: 'Submit', onPressed: () {}),
    ],
  ),
)
```

### Pattern 3: Responsive Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(context.responsive.radius20),
    ),
  ),
  builder: (context) => ResponsivePadding(
    all: 24,
    child: YourContent(),
  ),
);
```

## Support

For questions or issues with responsive design, please check:
1. This guide
2. The example implementations in `/lib/core/widgets/`
3. Create an issue in the project repository
