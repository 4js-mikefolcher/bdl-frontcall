# Genero BDL Frontcall Examples - Makefile

SRCDIR = source
WCDIR  = webcomponents

# Genero tools
FGLCOMP = fglcomp
FGLFORM = fglform

# Main programs
MAIN           = $(SRCDIR)/FrontcallExamples.42m
CLIPBOARD_DEMO = $(SRCDIR)/ClipboardDemo.42m

# 4GL source modules (FrontcallExamples and its IMPORT FGL dependencies)
MODULES_SRC = \
	FrontcallExamples.4gl \
	BrowserFC.4gl \
	LocalStorageFC.4gl \
	MonitorFC.4gl \
	StandardClipboard.4gl \
	StandardMisc.4gl \
	StandardNotification.4gl \
	StandardOS.4gl \
	TableFC.4gl \
	ThemeFC.4gl \
	WebComponentFC.4gl

# Standalone programs (separate MAIN, no IMPORT FGL dependencies)
STANDALONE_SRC = \
	ClipboardDemo.4gl

# Form source files
FORMS_SRC = \
	BrowserState.per \
	Clipboard.per \
	ClipboardDemo.per \
	ComposeMail.per \
	FileBrowse.per \
	FileExecute.per \
	FrontCallList.per \
	FrontendEnv.per \
	FrontendInfo.per \
	Geolocation.per \
	LocalStorage.per \
	MonitorUpdate.per \
	Notification.per \
	TableDemo.per \
	ThemeSelect.per \
	WebComponent.per \
	WebsiteLauncher.per \
	WindowSize.per

# Derived object lists
MODULES    = $(addprefix $(SRCDIR)/, $(MODULES_SRC:.4gl=.42m))
STANDALONE = $(addprefix $(SRCDIR)/, $(STANDALONE_SRC:.4gl=.42m))
FORMS      = $(addprefix $(SRCDIR)/, $(FORMS_SRC:.per=.42f))

# Imported modules (everything except the main)
LIB_MODULES = $(filter-out $(SRCDIR)/FrontcallExamples.42m, $(MODULES))

# Default target
all: $(FORMS) $(MODULES) $(STANDALONE)

# Main module depends on all library modules (IMPORT FGL)
$(SRCDIR)/FrontcallExamples.42m: $(LIB_MODULES)

# Pattern rules
$(SRCDIR)/%.42m: $(SRCDIR)/%.4gl
	cd $(SRCDIR) && $(FGLCOMP) $(notdir $<)

$(SRCDIR)/%.42f: $(SRCDIR)/%.per
	cd $(SRCDIR) && $(FGLFORM) $(notdir $<)

# Run the main program
run: all
	cd $(SRCDIR) && fglrun $(notdir $(MAIN))

# Run the clipboard demo
run-clipboard: all
	cd $(SRCDIR) && fglrun $(notdir $(CLIPBOARD_DEMO))

# Clean build artifacts
clean:
	rm -f $(SRCDIR)/*.42m $(SRCDIR)/*.42f

.PHONY: all run run-clipboard clean
