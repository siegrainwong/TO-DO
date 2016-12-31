#主要配置
##云函数代码
###配置方法
云引擎 > 部署 > 在线编辑 > 创建函数

创建之后点击**部署**即可，在你找到客户端对应的代码之前，**不要修改函数名及其代码**。

###代码
####函数1. 上传数据并保存服务器的同步记录
函数名： `commitTodos`
```js
    var todoArray = request.params.todos;
    var syncRecordDictionary = request.params.syncRecordDictionary;
    
    // 判断有没有数据要提交
    if(todoArray.length === 0){
        console.log('[todo]本次没有数据要提交，直接修改同步记录');
        // 2-1-3-1-2. 修改同步记录
        var paramsJson = { syncRecordDictionary: syncRecordDictionary };
        AV.Cloud.run('updateSyncRecord', paramsJson, {
            success: function(syncRecord) {
                console.log('[todo]提交完成');
                response.success(new Array(new Array(0), syncRecord));
            },
            error: function(error) {
                response.error(error);
            }
        });
    }else{
        // 构建Todo对象
        var todosAVArray = new Array(todoArray.length);
        // 这里保存的是本次提交中，新增的待办事项的索引
        var newTodoIndexArray = new Array();
        
        var Todo = AV.Object.extend('Todo');
        var newTodoIndex = 0;
        for(var i = 0; i < todoArray.length; i++){
            var avTodo = new Todo();
            var todo = todoArray[i];
            avTodo.set('id', todo.objectId);
            avTodo.set('objectId', todo.objectId);
            avTodo.set('title', todo.title);
            avTodo.set('sgDescription',todo.sgDescription);
            avTodo.set('deadline', todo.deadline);
            avTodo.set('user', todo.user);
            avTodo.set('status', todo.status);
            avTodo.set('isHidden', todo.isHidden);
            avTodo.set('isCompleted', todo.isCompleted);
            avTodo.set('photo', todo.photo);
            avTodo.set('syncVersion', todo.syncVersion);
            avTodo.set('localCreatedAt', todo.localCreatedAt);
            avTodo.set('localUpdatedAt', todo.localUpdatedAt);
            avTodo.set('deletedAt', todo.deletedAt);
            avTodo.set('completedAt', todo.completedAt);
            avTodo.set('identifier', todo.identifier);
            
            //2016-11-10：新增地址 
            // avTodo.set('location', todo.location);
            if(todo.generalAddress){
                avTodo.set('coordinate', new AV.GeoPoint(todo.coordinate.latitude, todo.coordinate.longitude));
                avTodo.set('generalAddress', todo.generalAddress);
                avTodo.set('explicitAddress', todo.explicitAddress);
            }
            
            todosAVArray[i] = avTodo;
            if(!todo.objectId){
                newTodoIndexArray[newTodoIndex] = i;
                newTodoIndex++;
            }
        }
        
        // 2-1-3-1-1. 提交待办事项
        AV.Object.saveAll(todosAVArray).then(function (avobjs) {
            // 2-1-3-1-2. 修改同步记录
            var paramsJson = { syncRecordDictionary: syncRecordDictionary };
            AV.Cloud.run('updateSyncRecord', paramsJson, {
                success: function(syncRecord) {
                    // 2-1-3-1-4. 将所有保存后的待办事项对象的objectId组成数组，和syncRecord一起返回
                    var todosObjectIdArray = new Array(newTodoIndexArray.length);
                    for(var i = 0;i < newTodoIndexArray.length;i++){
                        var newTodoIndex = newTodoIndexArray[i];
                        todosObjectIdArray[i] = todosAVArray[newTodoIndex].id;
                        console.log(todosObjectIdArray[i]);
                    }
                    console.log('[todo]提交完成');
                    response.success(new Array(todosObjectIdArray, syncRecord));
                },
                error: function(error) {
                    response.error('2-1-3-1-2 ::: ' + error);
                }
            });
        }, function (error) {
            response.error('2-1-3-1-1 ::: ' + error);
        });  
    }
```
####函数2. 根据编号获取同步记录，并标记为完成同步
函数名：`updateSyncRecord`
```js
    var syncRecordDictionary = request.params.syncRecordDictionary;
    
    var syncRecordId = syncRecordDictionary.syncRecordId;
    var commitCount = syncRecordDictionary.commitCount;
    var downloadCount = syncRecordDictionary.downloadCount;

    var query = new AV.Query('SyncRecord');
    // 2-1-3-1-2. 获取同步记录
    query.get(syncRecordId).then(function (syncRecord) {
        syncRecord.set('isFinished', true);
        syncRecord.set('commitCount', commitCount);
        syncRecord.set('downloadCount', downloadCount);
        syncRecord.set('syncEndTime', new Date());
        // 2-1-3-1-3. 修改同步记录
        syncRecord.save().then(function () {
            console.log('修改同步记录成功');
            response.success(syncRecord);
        }, function (error) {
            response.error('2-1-3-1-3 ::: ' + error);
        });
    }, function (error) {
        response.error('2-1-3-1-2 ::: ' + error);
    });
```