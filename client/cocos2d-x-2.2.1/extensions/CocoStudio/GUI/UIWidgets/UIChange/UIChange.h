#ifndef __UI_CHANGE__
#define __UI_CHANGE__

#include "../UIButton.h"
#include "../UICheckBox.h"
#include "../UIImageView.h"
#include "../UILabel.h"
#include "../UILabelAtlas.h"
#include "../UISlider.h"
#include "../UILabelBMFont.h"
#include "../UILoadingBar.h"
#include "../UITextField.h"
#include "../ScrollWidget/UIScrollView.h"

NS_CC_EXT_BEGIN;

class UIChange
{
public:
	static UIButton *UIWidget2UIButton(UIWidget *wid);
	static UICheckBox *UIWidget2UICheckBox(UIWidget *wid);
	static UIImageView *UIWidget2UIImageView(UIWidget *wid);
	static UILabel *UIWidget2UILabel(UIWidget *wid);
	static UILabelAtlas *UIWidget2UILabelAtlas(UIWidget *wid);
	static UISlider *UIWidget2UISlider(UIWidget *wid);
	static UILabelBMFont *UIWidget2UILabelBMFont(UIWidget *wid);
	static UILoadingBar *UIWidget2UILoadingBar(UIWidget *wid);
	static UITextField *UIWidget2UITextField(UIWidget *wid);
	static UIScrollView *UIWidget2UIScrollView(UIWidget *wid);

	
};
NS_CC_EXT_END;

#endif //__UI_CHANGE__