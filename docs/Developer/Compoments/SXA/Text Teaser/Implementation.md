
# Building a Dynamic Text Teaser Component in Sitecore SXA

---

## 1. Introduction

The homepage features several components: a carousel, call-to-action buttons, text teasers, services teasers, portfolio teasers, and client teasers. In this article, the focus is on creating the simple yet essential Text Teaser Component.

---

## 2. Understanding the SXA Toolbox and Renderings

- **The Toolbox:**
  SXA’s Experience Editor contains a “toolbox” – a container that organizes available components (or renderings) into sections for easy access by content authors.

- **Renderings:**
  Each page is built from renderings (components) that are added via drag-and-drop. Out-of-the-box, SXA provides basic renderings like images, videos, and rich text. However, you can easily create and customize your own renderings with custom logic, different view files, or by defining rendering variants.

The presenter explains that there are several approaches for customizing renderings:
  - **Overriding the View File:** Keeping the original file intact but providing a new file path.
  - **Using Rendering Variants:** Where the view is generic, and the actual markup is defined by variant definitions (items that specify a wrapping div, field renderers, etc.).
  - *(Advanced option)* Scripting the rendering entirely using Scriban.

For this tutorial, the focus is on using the out-of-the-box wizard to create a component and then adjusting its rendering variant.

---

## 3. Setting Up Your Module

### 3.1 Why Create a Module?
A module in SXA acts as a scaffold that pre-creates all the items needed for your component. This makes installation across multiple sites or tenants consistent and reduces the risk of missing items during setup.

### 3.2 Creating the Module
1. **Navigate to Settings → Feature:**
   The presenter reminds us that modules aren’t under “Modules” but under the Settings node in Sitecore.
2. **Create a Solution Folder:**
   For example, name it “SXA Tutorial.”
3. **Insert a New Module:**
   Using the insert option under the Feature node, create a module for the Text Teaser. In the wizard, select which folders to pre-create (renderings, placeholder settings, layouts, media library, etc.).
   - Choose to install the module on the site setup (not tenant setup) for component reuse.
4. **Confirm Module Creation:**
   The module is then created in a dedicated folder (e.g., under “SXA Tutorial > Text Teaser”).

*Tip:* The presenter notes that the pre-creation isn’t “set in stone” – you can always add or clean up items later.

---

## 4. Creating the Text Teaser Rendering

### 4.1 Inserting a New Component
1. **Navigate to Layouts/Renderings → Feature Folder:**
   Within your module’s folder, use the insert options to create a new component.
2. **Name Your Component:**
   Provide a name such as “Text Teaser.”
   - The module is automatically set based on your folder location.
3. **Provide a CSS Class:**
   Enter a CSS class (e.g., “text-teaser”) that will be added to the wrapping div of the view. This helps later with styling.
4. **Specify the View File:**
   You can leave the view path blank so that a new view is auto-created.
5. **Set Data Source Behavior:**
   Three options are offered:
   - **Ask the user for a data source (standard behavior).**
   - **Use the current page as the data source.**
   - **Automatically create the data source under the page’s data folder.**

   For this component, the presenter chooses to have the data source automatically created for a lightweight, “what you see is what you get” experience.
6. **Enable Component Variants:**
   Check the option to “Use Component Variant.” This allows authors to choose different visualizations (variants) for the component via a dropdown once it’s on the page.

### 4.2 Configuring Data Source Location
1. **Adjust Data Source Template/Location:**
   The default data source location (a query token path) is adjusted to point to a folder in your site’s data folder.
   - The presenter uses two queries—one for the local site context and one for shared content—ensuring compatibility with multi-site setups.
2. **Verify the Controller Assignment:**
   The rendering is assigned a standard SXA controller. Parameter templates and data source locations are also set.

---

## 5. Setting Up Templates and Rendering Variants

### 5.1 Creating the Data Template for Text Teaser
1. **Locate the Template Folder in Your Module:**
   Under your module (e.g., “Feature SXA Tutorial > Text Teaser”), you should see two folders: one for Data Sources and one for Rendering Parameters.
2. **Insert a New Template for the Text Teaser Folder:**
   - Create a template named “Text Teaser Folder” using the system templates.
   - Change its icon to represent a folder.
3. **Adjust Your Data Template Fields:**
   - **Label Field:** A single-line text field.
   - **Headline Field:** A single-line text field.
   - **Subheadline Field:** A multi-line text field.
   - **Content Field:** A rich text field (allowing lists and HTML markup).

### 5.2 Defining the Rendering Variant (Markup)
1. **Create a Variant Definition:**
   In your module, under Rendering Variance, create a new variant definition. For the Text Teaser, the default variant is usually sufficient.
2. **Define Markup Using Renderers:**
   - Start with a section renderer for the label. For example, wrap the label in a full-width `<div>` (using a bootstrap “col-12” class).
   - Next, create two columns using section renderers: one for the headline/subheadline and one for the content.
   - Insert field renderers for the headline (rendered as an H1) and the subheadline (as an H2). Finally, insert a field renderer for the content (rendered inside a `<p>` tag).
3. **Save and Verify:**
   The presenter shows that after saving, the rendering variant holds the “rough markup” for the component.

---

## 6. Installing the Module and Testing the Component

### 6.1 Installing the Module on the Site
1. **Use the Site’s Context Menu:**
   In the Content Editor, select the site item and choose “Scripts → Add Module.”
   - This installs any uninstalled modules. You should see your Text Teaser module appear; check it to install.
2. **Verify Folder Structure:**
   Ensure that the text teasers folder and available renderings are correctly created under the site.

### 6.2 Configuring the Toolbox
1. **Toolbox Setup:**
   Under available renderings, you can choose to group renderings by folder. The presenter recommends decluttering the toolbox so that only the components authors need are visible.
2. **Test Page Creation:**
   Create a new test page (e.g., “Text Teaser Test”).
3. **Drag and Drop the Component:**
   In the Experience Editor, drag the Text Teaser component from the toolbox onto the page.
4. **Set the Data Source:**
   When prompted, create a data source item (e.g., “Text Teaser Test”) and fill in the fields:
   - Label (e.g., “About Us”)
   - Headline
   - Subheadline
   - Rich text content (e.g., “Content ABC”)
5. **Preview and Save:**
   The component appears with its label, headline, subheadline, and content. Although it might need additional styling for centering, the basic functionality is in place.

---

## 7. Finalizing and Best Practices

- **Markup & Styling:**
  Once the component works functionally, adjust your CSS to center the component and style the typography as needed.

- **Rendering Variants:**
  Use rendering variants to allow authors to switch visual presentations from a dropdown. If more than 10 variants are used, consider splitting the functionality into separate renderings for clarity.

- **Content Management:**
  With the data source behavior set to “auto-create” or “ask the user,” authors have a “what you see is what you get” experience, reducing friction during content updates.

- **Toolbox Management:**
  Remove any unused components from the toolbox to enhance the authoring experience by decluttering the available options.

---

## 8. Conclusion

Drawing from the transcript, this tutorial has demonstrated how to build the Text Teaser Component in SXA by:
- Creating a dedicated module and scaffolding its items,
- Configuring a custom rendering with data source behavior and component variants,
- Defining a data template and rendering variant for the component’s markup,
- Installing the module on your site and testing the component in the Experience Editor.

Following these detailed, transcript-based instructions, you can create a dynamic, reusable Text Teaser Component that enhances your Sitecore website’s homepage and provides content authors with an intuitive editing experience.

---

*Note:* Replace placeholder screenshots and code snippets with your own visuals from your Sitecore environment to fully document your implementation.