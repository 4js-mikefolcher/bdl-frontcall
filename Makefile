# Genero BDL Frontcall Examples - Makefile
#
# Two output locations:
#   - com/fourjs/fclib/*.42m   ← fclib package (8 *Lib.4gl modules, declared PACKAGE com.fourjs.fclib)
#   - source/*.42m / *.42f     ← caller programs and forms (flat, non-packaged)

SRCDIR = source
PKGDIR = com/fourjs/fclib

# Genero tools
FGLCOMP = fglcomp
FGLFORM = fglform

# --- Library package sources (declare PACKAGE com.fourjs.fclib) -----------
LIB_PKG_SRC = \
	FrontCallLib.4gl \
	ClipboardLib.4gl \
	BrowserLib.4gl \
	LocalStorageLib.4gl \
	MonitorLib.4gl \
	OSLib.4gl \
	MiscLib.4gl \
	NotificationLib.4gl \
	WorkflowLib.4gl

# --- Caller 4GL modules (flat, imported by FrontcallExamples) -------------
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

# --- Standalone demo programs --------------------------------------------
STANDALONE_SRC = \
	ClipboardDemo.4gl \
	WebComponentDemo.4gl \
	BrowserDemo.4gl \
	LocalStorageDemo.4gl \
	MonitorDemo.4gl \
	NotificationDemo.4gl \
	ThemeDemo.4gl \
	StandardMiscDemo.4gl \
	StandardOSDemo.4gl \
	TableFCDemo.4gl \
	FileDemo.4gl \
	WorkflowDemo.4gl

# --- Form source files ---------------------------------------------------
FORMS_SRC = \
	BrowserState.per \
	Clipboard.per \
	ClipboardDemo.per \
	WebComponentDemo.per \
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
	WindowSize.per \
	BrowserDemo.per \
	LocalStorageDemo.per \
	MonitorDemo.per \
	NotificationDemo.per \
	ThemeDemo.per \
	StandardMiscDemo.per \
	StandardOSDemo.per \
	ThemeTree.per \
	FileDemo.per \
	WorkflowDemo.per

# --- Derived object lists -------------------------------------------------
LIB_PKG    = $(addprefix $(PKGDIR)/, $(LIB_PKG_SRC:.4gl=.42m))
MODULES    = $(addprefix $(SRCDIR)/, $(MODULES_SRC:.4gl=.42m))
STANDALONE = $(addprefix $(SRCDIR)/, $(STANDALONE_SRC:.4gl=.42m))
FORMS      = $(addprefix $(SRCDIR)/, $(FORMS_SRC:.per=.42f))

# Main program
MAIN           = $(SRCDIR)/FrontcallExamples.42m
CLIPBOARD_DEMO = $(SRCDIR)/ClipboardDemo.42m

# Callers that import the package depend on its modules
LIB_MODULES = $(filter-out $(SRCDIR)/FrontcallExamples.42m, $(MODULES))

all: $(FORMS) $(LIB_PKG) $(MODULES) $(STANDALONE)

# --- Package-internal dependencies ---------------------------------------
# FrontCallLib is foundational; every other lib depends on it.
$(PKGDIR)/ClipboardLib.42m:    $(PKGDIR)/FrontCallLib.42m
$(PKGDIR)/BrowserLib.42m:      $(PKGDIR)/FrontCallLib.42m
$(PKGDIR)/LocalStorageLib.42m: $(PKGDIR)/FrontCallLib.42m
$(PKGDIR)/MonitorLib.42m:      $(PKGDIR)/FrontCallLib.42m
$(PKGDIR)/OSLib.42m:           $(PKGDIR)/FrontCallLib.42m
$(PKGDIR)/MiscLib.42m:         $(PKGDIR)/FrontCallLib.42m
$(PKGDIR)/NotificationLib.42m: $(PKGDIR)/FrontCallLib.42m
$(PKGDIR)/WorkflowLib.42m:     $(PKGDIR)/FrontCallLib.42m $(PKGDIR)/OSLib.42m

# --- Caller dependencies on the package ----------------------------------
$(SRCDIR)/FrontcallExamples.42m: $(LIB_MODULES) $(LIB_PKG)

$(SRCDIR)/StandardClipboard.42m: $(PKGDIR)/ClipboardLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/ClipboardDemo.42m:     $(PKGDIR)/ClipboardLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/BrowserFC.42m:         $(PKGDIR)/BrowserLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/BrowserDemo.42m:       $(PKGDIR)/BrowserLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/LocalStorageFC.42m:    $(PKGDIR)/LocalStorageLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/LocalStorageDemo.42m:  $(PKGDIR)/LocalStorageLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/MonitorFC.42m:         $(PKGDIR)/MonitorLib.42m $(PKGDIR)/OSLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/MonitorDemo.42m:       $(PKGDIR)/MonitorLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/StandardOS.42m:        $(PKGDIR)/OSLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/StandardOSDemo.42m:    $(PKGDIR)/OSLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/FileDemo.42m:          $(PKGDIR)/OSLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/StandardMisc.42m:      $(PKGDIR)/MiscLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/StandardMiscDemo.42m:  $(PKGDIR)/MiscLib.42m $(PKGDIR)/OSLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/StandardNotification.42m: $(PKGDIR)/NotificationLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/NotificationDemo.42m:     $(PKGDIR)/NotificationLib.42m $(PKGDIR)/FrontCallLib.42m
$(SRCDIR)/WorkflowDemo.42m:         $(PKGDIR)/WorkflowLib.42m $(PKGDIR)/FrontCallLib.42m

# --- Pattern rules -------------------------------------------------------
# Package modules: compile from project root; PACKAGE declaration + --output-dir .
# causes fglcomp to place output under com/fourjs/fclib/
$(PKGDIR)/%.42m: $(SRCDIR)/%.4gl | $(PKGDIR)
	$(FGLCOMP) -M -Wall --output-dir . $<

# Caller modules: flat (no PACKAGE); compile from project root into $(SRCDIR)
$(SRCDIR)/%.42m: $(SRCDIR)/%.4gl
	$(FGLCOMP) -M -Wall --output-dir $(SRCDIR) $<

# Forms compile in-place
$(SRCDIR)/%.42f: $(SRCDIR)/%.per
	cd $(SRCDIR) && $(FGLFORM) $(notdir $<)

# Ensure the package output dir exists (phony target with | avoids re-runs)
$(PKGDIR):
	mkdir -p $(PKGDIR)

# --- Run targets (need FGLLDPATH to include project root so the package is found) ---
# Programs live in source/ and IMPORT FGL com.fourjs.fclib.* — the package lives at
# ../com/fourjs/fclib relative to source/, so we prepend ../ to FGLLDPATH when running.
FGLRUN = cd $(SRCDIR) && FGLLDPATH=..:$$FGLLDPATH fglrun

run: all
	$(FGLRUN) $(notdir $(MAIN))

run-clipboard: all
	$(FGLRUN) $(notdir $(CLIPBOARD_DEMO))

run-webcomponent: all
	$(FGLRUN) WebComponentDemo.42m

run-browser: all
	$(FGLRUN) BrowserDemo.42m

run-localstorage: all
	$(FGLRUN) LocalStorageDemo.42m

run-monitor: all
	$(FGLRUN) MonitorDemo.42m

run-notification: all
	$(FGLRUN) NotificationDemo.42m

run-theme: all
	$(FGLRUN) ThemeDemo.42m

run-misc: all
	$(FGLRUN) StandardMiscDemo.42m

run-os: all
	$(FGLRUN) StandardOSDemo.42m

run-table: all
	$(FGLRUN) TableFCDemo.42m

run-file: all
	$(FGLRUN) FileDemo.42m

run-workflow: all
	$(FGLRUN) WorkflowDemo.42m

# --- Clean build artifacts ------------------------------------------------
clean:
	rm -rf com $(SRCDIR)/*.42m $(SRCDIR)/*.42f

.PHONY: all run run-clipboard run-webcomponent run-browser run-localstorage \
        run-monitor run-notification run-theme run-misc run-os run-table run-file \
        run-workflow clean
