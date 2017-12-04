package ${packageName}.model;
 
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import android.arch.persistence.room.TypeConverter;
import java.util.List;
import com.google.gson.reflect.TypeToken;

<#list types.models + types.modelLists + types.enums as model> 
import ${model.fullPackageName};
</#list>

<#list types.enums as enum> 
import ${enum.class};
</#list>
 
@SuppressWarnings("unchecked")
public final class ModelTypeAdapters {
    private Gson mGson = new GsonBuilder().registerTypeAdapterFactory(ModelAdapterFactory.create()).create();
<#list types.models as model> 

    @TypeConverter
    public String from${model.name}(${model.name} ${model.name?uncap_first}) {
        return mGson.toJson(${model.name?uncap_first});
    }

    @TypeConverter
    public ${model.name} to${model.name}(String ${model.name?uncap_first}Json) {
        return mGson.fromJson(${model.name?uncap_first}Json, ${model.name}.class);
    }
</#list>
<#list types.modelLists as model> 

    @TypeConverter
    public String from${model.name}List(List<${model.name}> ${model.name?uncap_first}List) {
        return mGson.toJson(${model.name?uncap_first}List);
    }

    @TypeConverter
    public List<${model.name}> to${model.name}List(String ${model.name?uncap_first}Json) {
        return (List<${model.name}>) mGson.fromJson(${model.name?uncap_first}Json, new TypeToken<List<${model.name}>>(){}.getType());
    }
</#list>
<#list types.enums as enum> 

    @TypeConverter
    public String from${enum.name}(${enum.name} ${enum.name?uncap_first}) {
        return ${enum.name?uncap_first}.name();
    }

    @TypeConverter
    public ${enum.name} to${enum.name}List(String ${enum.name?uncap_first}String) {
        return ${enum.name}.valueOf(${enum.name?uncap_first}String); 
    }
</#list>

    // BEGIN PERSISTED SECTION - put custom methods here
    // END PERSISTED SECTION
}