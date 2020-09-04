import "Widgets" as Widgets

Widgets.ExpandableView {
   blurSource: root.bgItem
   isThemeDark: root.isThemeDark

   widgetWidth: AppSettings.expandableViewWidth
   animationDuration: AppSettings.expandableViewAnimationDuration
   headerHeight: AppSettings.expandableViewHeaderHeight
}
