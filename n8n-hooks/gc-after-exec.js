module.exports = {
  'workflowExecute.after'(data) {
    try {
      if (global.gc) {
        global.gc();
        console.log('[n8n hooks] GC executed after workflow.');
      }
    } catch (e) {
      console.error('[n8n hooks] GC failed', e);
    }
  },
};
